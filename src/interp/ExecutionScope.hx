package interp;

import core.BaseObject;
interface ExecutionScope extends BaseObject {
  function get(varName: String): Dynamic;
}