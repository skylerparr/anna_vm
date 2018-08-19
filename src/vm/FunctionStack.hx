package vm;

import lang.MatchValue;
import interp.ExecutionScope;
import lang.MatchData;

class FunctionStack {
  public var index: Int;
  public var terms: Array<MatchValue>;
  public var scope: ExecutionScope;

  public function new(terms:Array<MatchValue>, scope: ExecutionScope) {
    this.index = 0;
    this.terms = terms;
    this.scope = scope;
  }
}