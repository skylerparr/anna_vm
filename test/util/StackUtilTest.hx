package util;

import lang.MatchType;
import interp.StringMapExecutionScope;
import lang.Types;
import vm.FunctionStack;
import haxe.ds.GenericStack;
import massive.munit.Assert;


class StackUtilTest {
  @Test
  public function shouldCountTheNumberOfItemsInTheStack(): Void {
    var stack: GenericStack<FunctionStack> = new GenericStack<FunctionStack>();
    for(i in 0...25) {
      stack.add(new FunctionStack([{type: MatchType.CONSTANT, varName: null, value: "foo"}], new StringMapExecutionScope()));
    }
    Assert.areEqual(25, StackUtil.length(stack));
  }
}