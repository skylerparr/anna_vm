import massive.munit.TestSuite;

import core.ObjectFactoryTest;
import matcher.DefaultMatcherTest;
import interp.DefaultDataStructureInterpreterTest;
import vm.terms.VMFloatTest;
import vm.terms.VMIntegerTest;
import vm.terms.VMSmallUTF8AtomTest;
import vm.terms.VMStringTest;
import vm.terms.VMAtomTest;
import vm.terms.VMUTF8AtomTest;
import vm.DefaultSystemTest;
import lang.HashTableAtomsTest;

/**
 * Auto generated Test Suite for MassiveUnit.
 * Refer to munit command line tool for more information (haxelib run munit)
 */

class TestSuite extends massive.munit.TestSuite
{		

	public function new()
	{
		super();

		add(core.ObjectFactoryTest);
		add(matcher.DefaultMatcherTest);
		add(interp.DefaultDataStructureInterpreterTest);
		add(vm.terms.VMFloatTest);
		add(vm.terms.VMIntegerTest);
		add(vm.terms.VMSmallUTF8AtomTest);
		add(vm.terms.VMStringTest);
		add(vm.terms.VMAtomTest);
		add(vm.terms.VMUTF8AtomTest);
		add(vm.DefaultSystemTest);
		add(lang.HashTableAtomsTest);
	}
}
