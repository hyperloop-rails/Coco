import re
import rule
from constraint import InclusionConstraint


class ExtractQueryRule(rule.Rule):
    def __init__(self, cs) -> None:
        # cs is a non-empty list of constraints
 
        super().__init__(cs)
        self.name = "ExtractQuery"
        self.table_to_field = self.get_cs_map(cs)
        self.cs_tables = self.table_to_field.keys()
        self.inclusion_t = self.get_inclusion_table(cs)
        
        self.warning_cnt = 0

    def apply_single(self, q) -> list:
        if not 'from' in q:
            return []

        from_clause = q['from']
        select_clause = q['select'] if 'select' in q else q['select_distinct']

        # no JOIN case -> assume no table.field in anywhere (except table.*)
        if not self.contain_join(q):
            table = from_clause
            if isinstance(table, dict):
                # print("[Warning] Does not handle dict table (alias) %s for now" % table)
                return []
            if not table in self.cs_tables:
                return []
            if self.check_select(select_clause, table):
                return [q] 
            # note the structure of orderby_clause is the same as select_clause
            if "orderby" in q:
                orderby_clause = q['orderby']
                if self.check_select(orderby_clause):
                    return [q]
            if not 'where' in q: # can stop here
                return []
            where_clause = q['where'] 
            if self.check_where_simple(where_clause, table) or self.check_where(where_clause):
                return [q]
            return []

        else: # JOIN case -> only need to check whether table.field fits the map 
            if self.check_select(select_clause):
                return [q]
            # note the structure of orderby_clause is the same as select_clause
            if "orderby" in q:
                orderby_clause = q['orderby']
                if self.check_select(orderby_clause):
                    return [q]
            from_clause = q['from']
            if self.check_join_from(from_clause):
                return [q]
            if not 'where' in q:
                return []
            where_clause = q['where']
            if self.check_where(where_clause):
                return [q]
            
        return []

    #========================= helper function =======================

    # return a set of all tables that contains inclusion constraints 
    def get_inclusion_table(self, cs) -> set:
        inclusion_t = set()
        for c in cs:
            if type(c) == InclusionConstraint:
                inclusion_t.add(c.table)
        return inclusion_t

    # return a map: table(str) -> fields(set) 
    def get_cs_map(self, cs) -> dict:
        table_to_field = {}
        for c in cs:
            if not c.table in table_to_field.keys():
                table_to_field[c.table] = set()
            if isinstance(c.field, str):
                table_to_field[c.table].add(c.field)
            elif isinstance(c.field, list):
                table_to_field[c.table].union(set(c.field))
            elif c.field is None:
                print(c)
            else:
                print("[Error] extract rule does not handle field %s of type %s" % (c.field, type(c.field)))
        return table_to_field

    # return True if the query contain JOIN
    def contain_join(self, q) -> bool:
        if not 'from' in q:
            return False
        from_clause = q['from']
        return isinstance(from_clause, list)
  
    # select from no join simple case, only has one table
    def check_select(self, clause, table=None) -> bool:
        # {'value': 1, 'name': 'one'}
        # {'value': 'attachments.*'}
        def check_value_clause(clause):
            value = clause['value']
            if isinstance(value, int):
                return False
            if isinstance(value, dict):
                aggr_op = list(value.keys())[0]
                value = value[aggr_op]
            if "*" in value:
                return False
                return table in self.inclusion_t
            if not isinstance(value, str):
                return False
            elif table is not None and value in self.table_to_field[table]:
                return True
            elif "." in value:
                t, f = value.split(".")
                if t in self.cs_tables and f in self.table_to_field[t]:
                    return True
            else:
                return False
        if clause == "*":
            return table in self.inclusion_t
        if isinstance(clause, dict):
            return check_value_clause(clause)
        if isinstance(clause, list):
            for value_clause in clause:
                if check_value_clause(value_clause):
                    return True
        return False
    
    # check where in no join case
    def check_where_simple(self, clause, table) -> bool:
        # 'where': {'and': [{'eq': ['disk_filename', {'literal': '060719210727_archive.zip'}]}, {'neq': ['id', 21]}]}
        # {'eq': ['id', '$2']}
        op = list(clause.keys())[0]
        if op == "and" or op == "or":
            clause_list = clause[op]
            for item in clause_list:
                if self.check_where_simple(item, table):
                    return True
            return False
        else: # base case
            if op == "not":
                clause = clause[op]
                op = list(clause.keys())[0]
            
            if isinstance(clause[op], dict):
                keys = list(clause[op].keys())
                if len(keys) == 1:
                    key = keys[0]
                    value = clause[op][key]
                    table, field = value.split('.')
                    return field in self.table_to_field[table]
                else:
                    print("[Warning] 1. Does not handle predicate %s of type %s for now" % (clause[op], type(clause[op])))
                    self.warning_cnt += 1
                    return False
            if isinstance(clause[op], str):
                items = clause[op].split('.')
                if len(items) == 1:
                    return items[0] in self.table_to_field[table]
                elif len(items) == 2:
                    t, f = items
                    return f in self.table_to_field[t]
                else:
                    print("[Error] Unidentified field %s" % clause[op])
                    return False
            if not isinstance(clause[op], list):
                print("[Warning] 2. Does not handle predicate %s of type %s for now" % (clause[op], type(clause[op])))
                self.warning_cnt += 1
                return False
            if isinstance(clause[op][0], int):
                return False
            if isinstance(clause[op][0], dict):
                keys = list(clause[op][0].keys())
                if len(keys) == 1:
                    key = keys[0]
                    value = clause[op][0][key]
                    if not isinstance(value, str):
                        return False
                    tokens = value.split('.')
                    if len(tokens) == 1:
                        return False # does not handle field without table name
                    table, field = tokens
                    return field in self.table_to_field[table]
            if not isinstance(clause[op][0], str):
                print("[Warning] 3. Does not handle predicate %s of type %s for now" % (clause[op][0], type(clause[op][0])))
                self.warning_cnt += 1
                return False
            return clause[op][0] in self.table_to_field[table]

    # check on_clause inside from_clause
    def check_join_from(self, clause) -> bool:
        # We assume there are no 
        # inclusion/format/length constraint fields
        # in the join predicate
        if isinstance(clause, dict) and "on" in clause[1].keys():
            on_clause = clause[1]["on"]
            if self.check_where(on_clause):
                return True
        return False

    # check where clauses, return true if where clause contain inclusion constraints, otherwise false
    def check_where(self, clause) -> bool:
        def check_field(s):
            items = s.split(".")
            if len(items) == 1:
                # print("[Warning] Does not handle field %s without table name" % s)
                self.warning_cnt += 1
                return False
            t, f = items
            return t in self.cs_tables and f in self.table_to_field[t]
            
        if not isinstance(clause, dict):
            print("[Warning] Cannot handle clause of %s, expect dict" % clause)
            self.warning_cnt += 1
            return False
        op = list(clause.keys())[0]
        if op == "and" or op == "or":
            clause_list = clause[op]
            for item in clause_list:
                if self.check_where(item):
                    return True
        # base case: does not contain and/or
        else:
            if isinstance(clause[op], str):
                return check_field(clause[op])
        
            if not isinstance(clause[op], list):
                print("[Warning] Does not handle clause %s of type %s, expect list" %(clause[op], type(clause[op])))
                self.warning_cnt += 1
                return False
            
            if not isinstance(clause[op][0], str):
                return False
            
            return check_field(clause[op][0])
        