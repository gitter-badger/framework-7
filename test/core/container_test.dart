import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import 'package:bridge/core.dart';
import 'dart:async';
import 'dart:mirrors';

class ContainerTest implements TestCase {

  Container container;

  setUp() {
    container = new Container();
  }

  tearDown() {
  }

  @test
  it_instantiates_a_class() {
    expect(container.make(LonelyClass) is LonelyClass, isTrue);
  }

  @test
  it_instantiates_the_dependencies_of_the_class() {
    expect(container.make(ClassDependingOnClass) is ClassDependingOnClass, isTrue);
  }

  @test
  it_throws_an_exception_when_cant_instantiate() {
    expect(new Future.microtask(() => container.make(Interface)), throws);
  }

  @test
  it_binds_an_implementing_class_to_an_interface() {
    container.bind(Interface, ClassImplementingInterface);

    expect(container.make(Interface) is ClassImplementingInterface, isTrue);
  }

  @test
  it_resolves_a_functions_arguments() {
    var closure = (LonelyClass d) => d;

    expect(container.resolve(closure) is LonelyClass, isTrue);
  }

  @test
  it_binds_an_instance_as_a_singleton() {
    var instance = new LonelyClass();
    container.singleton(instance);

    expect(container.make(LonelyClass) == instance, isTrue);
  }

  @test
  it_binds_a_singleton_to_an_interface() {
    var instance = new ClassImplementingInterface();
    container.singleton(instance, as: Interface);

    expect(container.make(Interface) == instance, isTrue);
  }

  @test
  it_can_send_through_a_temporary_singleton() {
    var wasCalled = false;
    var instance = new ClassImplementingInterface();
    var closure = (Interface dependency) {
      expect(instance, equals(dependency));
      wasCalled = true;
    };
    container.resolve(closure, injecting: {
      Interface: instance
    });
    expect(wasCalled, isTrue);
  }

  @test
  it_can_make_the_temporary_singleton_propagate_to_dependencies() {
    var wasCalled = false;
    var instance = new ClassImplementingInterface();
    var closure = (ClassDependingOnInterface dependency) {
      expect(instance, equals(dependency.dependency));
      wasCalled = true;
    };
    container.resolve(closure, injecting: {
      Interface: instance
    });
    expect(wasCalled, isTrue);
  }

  @test
  it_retains_type_arguments_when_resolving_a_dependency() {
    closure(ClassWithTypeArgument<LonelyClass> dependency) {
      return reflect(dependency).type.typeArguments[0].reflectedType;
    }
    var type = container.resolve(closure);
    expect(type, equals(LonelyClass));
  }

  @test
  it_can_create_an_auto_resolving_function() {
    var lonely = new LonelyClass();
    var wasCalled = false;
    var function = (ClassWithTypeArgument<String> dep, LonelyClass lonelyClass) {
      expect(dep, new isInstanceOf<ClassWithTypeArgument<String>>());
      expect(lonelyClass, equals(lonely));
      wasCalled = true;
    };
    var autoResolvingFunction = container.presolve(function);
    autoResolvingFunction(lonely);
    expect(wasCalled, isTrue);
  }
}

class LonelyClass {
}

class ClassDependingOnClass {
  LonelyClass dependency;

  ClassDependingOnClass(LonelyClass this.dependency);
}

abstract class Interface {
}

class ClassImplementingInterface implements Interface {
}

class ClassDependingOnInterface {
  Interface dependency;

  ClassDependingOnInterface(Interface this.dependency);
}

class ClassWithTypeArgument<T> {

}