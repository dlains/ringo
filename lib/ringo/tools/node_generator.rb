require 'yaml'

module Ringo::Tools

  # Generates AST node classes dynamically from a YAML file. The +node_descriptions.yml+ file
  # holds the data for all of the AST node classes. It has the form:
  #   class_name:
  #     extends: base_class
  #     attributes:
  #       attribute_name: attribute_type
  #
  # For example, the following YAML:
  #   unary:
  #     extends: Ringo::Expr
  #     attributes:
  #       operator: Ringo::Token
  #       right: Ringo::Expr
  #
  # Will generate a class that looks like:
  # module Ringo
  #   class Unary
  #     def initialize(operator, right)
  #       @operator = operator
  #       @right = right
  #     end
  #
  #     def operator
  #       @operator
  #     end
  #
  #     def operator=(value)
  #       @operator = value
  #     end
  #
  #     def right
  #       @right
  #     end
  #
  #     def right=(value)
  #       @right = value
  #     end
  #
  #     def accept(visitor)
  #       visitor.send('visit_unary', self)
  #     end
  #   end
  # end
  #
  # The code generator does not currently use the +attribute_type+ data, but I left
  # it in place for reference.
  #
  # The YAML file is read and all of the classes are dynamically added to the Ringo
  # module.
  class NodeGenerator

    # Perform the node generaction steps.
    # The +file_path+ is the fullly qualified path to a YAML file with AST node
    # descriptions.
    def self.run(file_path)
      descriptions = YAML.load_file(file_path)

      # Generate a class for each top level key.
      descriptions.each do |name, data|
        # Make sure the new class is added to the Ringo module.
        Ringo.module_exec {
          klass = Class.new(Kernel.const_get(data['extends'])) do

            # If there is an attributes key, add the class initializer and the attribute methods.
            if data.has_key?('attributes')

              # Get all of the attributes keys, they become the arguments.
              # def initialize(attr1, attr2, ...)
              #   @attr1 = attr1
              #   @attr2 = attr2
              # end
              arg_list = data['attributes'].keys
              define_method :initialize do |*args|
                arg_list.zip(args) do |name, value|
                  instance_variable_set("@#{name}", value)
                end
              end

              # Cycle through all of the attributes and create the getter and
              # setter methods.
              data['attributes'].each do |attr_name, type|
                define_method attr_name.intern do
                  instance_variable_get("@#{attr_name}")
                end
                define_method "#{attr_name}=".intern do |arg|
                  instance_variable_set("@#{attr_name}", arg)
                end
              end

              # Define the accept method to allow for visitors.
              define_method :accept do |visitor|
                visitor.send("visit_#{name}", self)
              end
            end
          end

          # Assign the class name to the klass variable.
          const_set(name.capitalize, klass)
        }
      end

    end
  end
end
