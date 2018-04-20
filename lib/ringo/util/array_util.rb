module Ringo::Util

  # ArrayUtil
  #
  # I don't think this code will survive for long. I'm simply trying to reproduce
  # some of the code from the first chapter of EOPL. This is basically a tutorial
  # on writing recursive code.
  class ArrayUtil

    # Returns the length of an array. Uses a recursive algorithm rather than
    # array.size.
    def length(array)
      return 0 if array.nil? || array.empty?
      return 1 + length(array.slice(1, array.size))
    end

    # Returns the element at index n.
    #
    # Raises ArgumentError if array is nil or empty.
    def element_at(array, n)
      raise ArgumentError.new('The array can not be empty') if array.nil? || array.empty?
      return array.slice(n) if n.zero?
      return element_at(array.slice(1, array.size), n - 1)
    end
  end
end
