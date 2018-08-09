import massive.munit.TestSuite;

import core.ObjectFactoryTest;
import exec.DefaultTermExecuterTest;
import interp.DefaultDataStructureInterpreterTest;
import lang.HashTableAtomsTest;
import matcher.DefaultMatcherTest;
import vm.DefaultSystemTest;
import vm.terms.VMAtomTest;
import vm.terms.VMFloatTest;
import vm.terms.VMIntegerTest;
import vm.terms.VMSmallUTF8AtomTest;
import vm.terms.VMStringTest;
import vm.terms.VMUTF8AtomTest;

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
		add(exec.DefaultTermExecuterTest);
		add(interp.DefaultDataStructureInterpreterTest);
		add(lang.HashTableAtomsTest);
		add(matcher.DefaultMatcherTest);
		add(vm.DefaultSystemTest);
		add(vm.terms.VMAtomTest);
		add(vm.terms.VMFloatTest);
		add(vm.terms.VMIntegerTest);
		add(vm.terms.VMSmallUTF8AtomTest);
		add(vm.terms.VMStringTest);
		add(vm.terms.VMUTF8AtomTest);
	}
}
