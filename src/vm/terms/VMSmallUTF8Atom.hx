package vm.terms;
class VMSmallUTF8Atom implements Term {

  private var value: String;

  public function new(value: String) {
    this.value = value;
  }

  public function eval():Dynamic {
    return value;
  }
}
