package core;
interface ObjectCreator {
    function createInstance(clazz: Class<Dynamic>, ?constructorArgs: Array<Dynamic>, ?initArgs: Array<Dynamic>): Dynamic;
    function disposeInstance(object: Dynamic): Void;
}
