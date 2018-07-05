package vm;
import haxe.io.Bytes;
interface System {
  function binaryToTerm(bytes: Bytes): Term;
}
