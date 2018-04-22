module Ringo
  # Utility methods that are used by the interpreter.
  module Util
    # Returns the length of a list. Uses a recursive algorithm rather than
    # array.size.
    def Util.length(list)
      return 0 if list.nil? || list.empty?
      return 1 + length(cdr(list))
    end

    # Returns the element at index n.
    #
    # Raises ArgumentError if list is nil or empty.
    def Util.element_at(list, n)
      raise ArgumentError.new('The array can not be empty') if list.nil? || list.empty?
      return car(list) if n.zero?
      return element_at(cdr(list), n - 1)
    end
  end

  # Duplicate +value+ +count+ times into a list.
  #
  # Returns an list with +count+ entries of +value+.
  def Util.duple(count, value)
    return [] if count.zero?
    return [value] + duple(count - 1, value)
  end

  # Wrap each element in +list+ in its own list.
  #
  # Return the resulting list.
  def Util.down(list)
    raise ArgumentError.new('Can only down a list') unless list.is_a?(Array)
    raise ArgumentError.new('Can not down an empty list') if list.empty?
    return list.map { |elem| [elem] }
  end

  # Swap every +e1+ with +e2+ in the +list+.
  #
  # Return the resulting list.
  def Util.swapper(e1, e2, list)
    return list if list.nil? || list.empty?
    return list.map { |elem| swap_in_element(e1, e2, elem) }
  end

  # Auxiliary method used by *swapper*. Does the swap unless the elem is an Array.
  #
  # Returns the swapped element or the element itself if it doesn't match e1 or e2.
  def Util.swap_in_element(e1, e2, elem)
    return swapper(e1, e2, elem) if elem.is_a?(Array)
    return e2 if elem == e1
    return e1 if elem == e2
    return elem
  end

  # Filter an list using the supplied predicate.
  #
  # Returns a list where all elements match the predicate.
  def Util.filter_in(list, pred)
    return list if list.nil? || list.empty?
    return [car(list)] + filter_in(cdr(list), pred) if pred.call(car(list))
    return filter_in(cdr(list), pred)
  end

  # Check every element in list agains the predicate.
  #
  # Returns true if every element satisfies the predicate, false otherwise.
  def Util.every?(list, pred)
    return true if list.empty?
    return every?(cdr(list), pred) if pred.call(car(list))
    return false
  end

  # The car of a list is the first element.
  #
  # Return the first element of the list.
  # Raises ArgumentError if the list is empty.
  # Raises ArgumentError if the list is not an array.
  def Util.car(list)
    raise ArgumentError.new('Can only get the car from a list') unless list.is_a?(Array)
    raise ArgumentError.new('Can not get the car from an empty list') if list.empty?
    return list.at(0)
  end

  # The cdr of a list is the entire list minus +car(list)+.
  #
  # Return all but the first element of the list.
  # Raises ArgumentError if the list is empty.
  # Raises ArgumentError if the list is not an array.
  def Util.cdr(list)
    raise ArgumentError.new('Can only get the cdr from a list') unless list.is_a?(Array)
    raise ArgumentError.new('Can not get the cdr from an empty list') if list.empty?
    return list.slice(1, list.size)
  end
end
