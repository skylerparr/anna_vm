package lang;
import lang.Types.Atom;
class Atoms {

    public static var NIL: Atom = {value: "nil", type: Types.ATOM};
    public static var TRUE: Atom = {value: "true", type: Types.ATOM};
    public static var FALSE: Atom = {value: "false", type: Types.ATOM};

    public static var Kernel: Atom = {value: "Kernel", type: Types.ATOM};
    public static var Plus: Atom = {value: "+", type: Types.ATOM};

    private static var atoms: Map<String, Atom> = {
        var map = new Map<String, Atom>();
        map.set("nil", NIL);
        map.set("true", TRUE);
        map.set("false", FALSE);
        map.set("Kernel", Kernel);
        map.set("+", Plus);
        map;
    }

    public function new() {
    }
}
