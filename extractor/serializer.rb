require 'json'
require 'oj'
require_relative 'constraint'
require_relative 'class_node'

class TreeVisitor
  attr_accessor :constraints, :constraints_cnt

  def initialize(for_rewrite)
    @constraints = []
    @constraints_cnt = {}
    @for_rewrite = for_rewrite
    ConstrainType.constants.each do |t|
      @constraints_cnt[t] = 0
    end
  end

  def visit(node, _params)
    if node.table.nil?
      # puts "#{node.parent}"
      return
    end

    if @for_rewrite && !(['ActiveRecord::Base', 'Principal', 'ApplicationRecord', 'Spree::Base'].include? node.parent)
      return
    end

    c = Serializer.serialize_node(node)
    @constraints << c
    ConstrainType.constants.each do |t|
      @constraints_cnt[t] += node.constraints.select { |con| con.ctype == t.to_s }.length
    end
  end
end

class Serializer
  def self.deserialize_node(node_obj)
    node = ClassNode.new(node_obj['name'])
    node.parent = node_obj['parent']
    node.constants = node_obj['constants']
    node.ast = node_obj['ast']
    node.table = node_obj['table']
    node.children = node_obj['children']
    node.constraints = Oj.load(node_obj['constraints'].to_json)
    node
  end

  def self.serialize_node(node)
    node.constraints.each do |c|
      c.cond = c.cond.to_s if c.class.method_defined? :cond
    end
    # only serialize constraints of specific types
    skip_types = [
      HasOneManyConstraint
    ]
    dump_constrains = node.constraints.reject { |c| skip_types.include? c.class }
    dump_constrains = dump_constrains.uniq
    {
      table: node.table,
      parent: node.parent,
      class: node.name,
      constraints: (JSON.parse Oj.dump(dump_constrains))
    }
  end

  def self.deserialize_tree(filename)
    file = File.read(filename)
    data_hash = JSON.parse(file)
    nodes = []
    name_node_map = {}
    data_hash.each do |node_obj|
      node = deserialize_node(node_obj)
      name_node_map[node_obj['name']] = node
      nodes << node
    end
    root = nil
    nodes.each do |node|
      if name_node_map.key? node.parent
        node.parent = name_node_map[node.parent]
      else
        node.parent = nil
        root = node
      end
      children = []
      node.children.each do |childname|
        children << name_node_map[childname]
      end
      node.children = children
    end
    root
  end

  def self.serialize_tree(root, output_filename, for_rewrite)
    visitor = TreeVisitor.new(for_rewrite)
    t = Traversor.new(visitor)
    t.traverse(root)
    File.open(output_filename, 'w') do |f|
      f.write(JSON.pretty_generate(visitor.constraints))
    end
  end
end
