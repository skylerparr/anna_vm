package vm;

import lang.MatchValue;
enum ResultType {
  CONSTANT;
  PUSH_STACK;
  WAITING;
  ERROR;
}

typedef ExecutionResult = {
  type: ResultType,
  value: MatchValue
}