package lang;
enum Types {
    ATOM;
    TUPLE;
    LIST;
    MAP;
}
typedef Tuple = {
    value: Array<Dynamic>,
    type: Types
}

typedef Atom = {
    value: String,
    type: Types
}

typedef LinkedList = {
    value: List<Dynamic>,
    type: Types
}

typedef MatchMap = {
    value: haxe.ds.ObjectMap<Dynamic, Dynamic>,
    type: Types
}