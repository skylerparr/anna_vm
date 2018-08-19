package util;
import vm.FunctionStack;
import haxe.ds.GenericStack;
class StackUtil {
  public static inline function length(stack: GenericStack<FunctionStack>): Int {
    var counter: Int = 0;
    for(i in stack.iterator()) {
      counter++;
    }
    return counter;
  }
}