package vm.terms;
class VMFloat implements Term {

  private var value: Float;

  public function new(value: Float) {
    this.value = value;
  }

  public function eval():Dynamic {
    return value;
  }
}
