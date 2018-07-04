package vm.terms;
class VMInteger implements Term {

  private var value: Int;

  public function new(value: Int) {
    this.value = value;
  }

  public function eval():Dynamic {
    return value;
  }
}
