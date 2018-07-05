package vm;
import const.ByteCodes;
import error.InvalidByteCodeError;
import haxe.io.Bytes;
import haxe.io.BytesData;
import vm.terms.VMAtom;
import vm.terms.VMFloat;
import vm.terms.VMInteger;
import vm.terms.VMSmallUTF8Atom;
import vm.terms.VMString;
import vm.terms.VMUTF8Atom;

class DefaultSystem implements System {


  public function new() {
  }

  public function binaryToTerm(bytes:Bytes):Term {
    var data: BytesData = bytes.getData();
    if(Bytes.fastGet(data, 0) == ByteCodes.START) {
      switch Bytes.fastGet(data, 1) {
        case ByteCodes.INTEGER:
          return new VMInteger(Bytes.fastGet(data, 2));
        case ByteCodes.FLOAT:
          return new VMFloat(bytes.getFloat(2));
        case ByteCodes.STRING:
          return new VMString(bytes.getString(6, bytes.getInt32(2)));
        case ByteCodes.ATOM:
          var length: Int = Bytes.fastGet(data, 2) + Bytes.fastGet(data, 3);
          return new VMAtom(bytes.getString(4, length));
        case ByteCodes.SMALL_UTF8_ATOM:
          var length: Int = Bytes.fastGet(data, 2);
          return new VMSmallUTF8Atom(bytes.getString(3, length));
        case ByteCodes.UTF8_ATOM:
          var length: Int = Bytes.fastGet(data, 2);
          return new VMUTF8Atom(bytes.getString(3, length));
      }
    }
    throw new InvalidByteCodeError("Unable to interpret byte code start " + Bytes.fastGet(data, 0));
  }
}
