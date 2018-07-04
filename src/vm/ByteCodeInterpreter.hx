package vm;
import haxe.io.Bytes;
interface ByteCodeInterpreter {
  function interpret(bytes: Bytes): Term;
}
