## Google Python Style Guide

### 1 Background

Python is the main dynamic language used at Google. This style guide is a list of dos and donʼts for Python programs.

To help you format code correctly, weʼve created a. For Emacs, the default settings should be fine.

Many teams use the or auto-formatter to avoid arguing over formatting.

### 2 Python Language Rules

#### 2.1 Lint

Run pylint over your code using this.

##### 2.1.1 Definition

pylint is a tool for finding bugs and style problems in Python source code. It finds problems that are typically

caught by a compiler for less dynamic languages like C and C++. Because of the dynamic nature of Python, some
warnings may be incorrect; however, spurious warnings should be fairly infrequent.

##### 2.1.2 Decision

Make sure you run pylint on your code.

Suppress warnings if they are inappropriate so that other issues are not hidden. To suppress warnings, you can set a line-level comment:

```
def do_PUT(self):  # WSGI name, so pylint: disable=invalid-name
  ...
```

pylint warnings are each identified by symbolic name (empty-docstring) Google-specific warnings start with g-.

If the reason for the suppression is not clear from the symbolic name, add an explanation.

Suppressing in this way has the advantage that we can easily search for suppressions and revisit them.

You can get a list of pylint warnings by doing:

```
pylint --list-msgs
```

To get more information on a particular message, use:


```
pylint --help-msg=invalid-name

```

Prefer pylint: disable to the deprecated older form pylint: disable-msg.

Unused argument warnings can be suppressed by deleting the variables at the beginning of the function. Always include a comment explaining why you are deleting it. “Unused.” is sufficient. For example:


```
def viking_cafe_order(spam: str, beans: str, eggs: str | None = None) -> str:
    del beans, eggs # Unused by vikings.
    return spam + spam + spa
```

Other common forms of suppressing this warning include using ‘_ʼ as the identifier for the unused argument or prefixing the argument name with ‘unused_ʼ, or assigning them to ‘_ʼ. These forms are allowed but no longer encouraged. These break callers that pass arguments by name and do not enforce that the arguments are actually
unused.

#### 2.2 Imports

Use import statements for packages and modules only, not for individual types, classes, or functions.

##### 2.2.1 Definition

Reusability mechanism for sharing code from one module to another.

##### 2.2.2 Decision

- Use import x for importing packages and modules.
- Use from x import y where x is the package prefix and y is the module name with no prefix.
- Use from x import y as z in any of the following circumstances:
    - Two modules named y are to be imported.
    - y conflicts with a top-level name defined in the current module.
    - y conflicts with a common parameter name that is part of the public API (e.g., features).
    - y is an inconveniently long name.
    - y is too generic in the context of your code (e.g., from storage.file_system import options as fs_options).
- Use import y as z only when z is a standard abbreviation (e.g., import numpy as np).

For example the module sound.effects.echo may be imported as follows:

```
from sound.effects import echo
...
echo.EchoFilter(input, output, delay=0.7, atten=4)
```

Do not use relative names in imports. Even if the module is in the same package, use the full package name. This
helps prevent unintentionally importing a package twice.

###### 2.2.2.1 Exemptions

Exemptions from this rule:

- Symbols from the following modules are used to support static analysis and type checking:
    - typing
   - collections.abc
   - typing_extensions
- Redirects from the.

#### 2.3 Packages

Import each module using the full pathname location of the module.

##### 2. 3. 1 Decision

All new code should import each module by its full package name.

Imports should be as follows:

```
Yes:
  # Reference absl.flags in code with the complete name (verbose).
  import absl.flags
  from doctor.who import jodie
  _FOO = absl.flags.DEFINE_string(...)
```
```
Yes:
  # Reference flags in code with just the module name (common).
  from absl import flags
  from doctor.who import jodie
  _FOO = flags.DEFINE_string(...)
```

(assume this file lives in doctor/who/ where jodie.py also exists)

```
No:
  # Unclear what module the author wanted and what will be imported.  The actual
  # import behavior depends on external factors controlling sys.path.
  # Which possible jodie module did the author intend to import?
  import jodie
```

The directory the main binary is located in should not be assumed to be in sys.path despite that happening in some environments. This being the case, code should assume that import jodie refers to a third-party or top-level package named jodie, not a local jodie.py.

#### 2.4 Exceptions

Exceptions are allowed but must be used carefully.

##### 2.4.1 Definition

Exceptions are a means of breaking out of normal control flow to handle errors or other exceptional conditions.

##### 2.4.2 Decision

Exceptions must follow certain conditions:

- Make use of built-in exception classes when it makes sense. For example, raise a ValueError to indicate a programming mistake like a violated precondition, such as may happen when validating function arguments.
- Do not use assert statements in place of conditionals or validating preconditions. They must not be critical to the application logic. A litmus test would be that the assert could be removed without breaking the code. assert conditionals are to be evaluated. For based tests, assert is okay and expected to verify expectations. For example:

```
Yes:
  def connect_to_next_port(self, minimum: int) -> int:
    """Connects to the next available port.
    Args:
      minimum: A port value greater or equal to 1024.
    Returns:
      The new minimum port.
    Raises:
      ConnectionError: If no available port is found.
    """
    if minimum < 1024:
      # Note that this raising of ValueError is not mentioned in the doc
      # string's "Raises:" section because it is not appropriate to
      # guarantee this specific behavioral reaction to API misuse.
      raise ValueError(f'Min. port must be at least 1024, not {minimum}.')
    port = self._find_next_open_port(minimum)
    if port is None:
      raise ConnectionError(
          f'Could not connect to service on port {minimum} or higher.')
    # The code does not depend on the result of this assert.
    assert port >= minimum, (
        f'Unexpected port {port} when minimum was {minimum}.')
    return port
```

```
No:
  def connect_to_next_port(self, minimum: int) -> int:
    """Connects to the next available port.
    Args:
      minimum: A port value greater or equal to 1024.
    Returns:
      The new minimum port.
    """
    assert minimum >= 1024, 'Minimum port must be at least 1024.'
    # The following code depends on the previous assert.
    port = self._find_next_open_port(minimum)
    assert port is not None
    # The type checking of the return statement relies on the assert.
    return port

```

- Libraries or packages may define their own exceptions. When doing so they must inherit from an existing exception class. Exception names should end in Error and should not introduce repetition (foo.FooError).
- Never use catch-all except: statements, or catch Exception or StandardError, unless you are
    - re-raising the exception, or
    - creating an isolation point in the program where exceptions are not propagated but are recorded and suppressed instead, such as protecting a thread from crashing by guarding its outermost block.

Python is very tolerant in this regard and except: will really catch everything including misspelled names, sys.exit() calls, Ctrl+C interrupts, unittest failures and all kinds of other exceptions that you simply donʼt want to
catch.

- Minimize the amount of code in a try/except block. The larger the body of the try, the more likely that an exception will be raised by a line of code that you didnʼt expect to raise an exception. In those cases, the try/except block hides a real error.
- Use the finally clause to execute code whether or not an exception is raised in the try block. This is often useful for cleanup, i.e., closing a file.

#### 2.5 Mutable Global State

Avoid mutable global state.

##### 2.5.1 Definition

Module-level values or class attributes that can get mutated during program execution.

##### 2.5.2 Decision

Avoid mutable global state.

In those rare cases where using global state is warranted, mutable global entities should be declared at the module level or as a class attribute and made internal by prepending an _ to the name. If necessary, external access to mutable global state must be done through public functions or class methods. See below. Please explain the
design reasons why mutable global state is being used in a comment or a doc linked to from a comment.

Module-level constants are permitted and encouraged. For example: _MAX_HOLY_HANDGRENADE_COUNT = 3 for an internal use constant or SIR_LANCELOTS_FAVORITE_COLOR = "blue" for a public API constant. Constants must be named using all caps with underscores. See below.

#### 2.6 Nested/Local/Inner Classes and Functions

Nested local functions or classes are fine when used to close over a local variable. Inner classes are fine.

##### 2.6.1 Definition

A class can be defined inside of a method, function, or class. A function can be defined inside a method or function.
Nested functions have read-only access to variables defined in enclosing scopes.

##### 2.6.2 Decision

They are fine with some caveats. Avoid nested functions or classes except when closing over a local value other than self or cls. Do not nest a function just to hide it from users of a module. Instead, prefix its name with an _ at the module level so that it can still be accessed by tests.

#### 2.7 Comprehensions & Generator Expressions

Okay to use for simple cases.

##### 2.7.1 Definition

List, Dict, and Set comprehensions as well as generator expressions provide a concise and efficient way to create container types and iterators without resorting to the use of traditional loops, map(), filter(), or lambda.

##### 2.7.2 Decision

Comprehensions are allowed, however multiple for clauses or filter expressions are not permitted. Optimize for readability, not conciseness.

```
Yes:
  result = [mapping_expr for value in iterable if filter_expr]
  result = [
      is_valid(metric={'key': value})
      for value in interesting_iterable
      if a_longer_filter_expression(value)
  ]
  descriptive_name = [
      transform({'key': key, 'value': value}, color='black')
      for key, value in generate_iterable(some_input)
      if complicated_condition_is_met(key, value)
  ]
  result = []
  for x in range(10):
    for y in range(5):
      if x * y > 10:
        result.append((x, y))
  return {
      x: complicated_transform(x)
      for x in long_generator_function(parameter)
      if x is not None
  }
  return (x**2 for x in range(10))
  unique_names = {user.name for user in users if user is not None}
```

```
No:
  result = [(x, y) for x in range(10) for y in range(5) if x * y > 10]
  return (
      (x, y, z)
      for x in range(5)
      for y in range(5)
      if x != y
      for z in range(5)
      if y != z
  )
```

#### 2.8 Default Iterators and Operators

Use default iterators and operators for types that support them, like lists, dictionaries, and files.

##### 2.8.1 Definition

Container types, like dictionaries and lists, define default iterators and membership test operators (“in” and “not in”).

##### 2.8.2 Decision

Use default iterators and operators for types that support them, like lists, dictionaries, and files. The built-in types
define iterator methods, too. Prefer these methods to methods that return lists, except that you should not mutate a
container while iterating over it.

```
Yes:  for key in adict: ...
      if obj in alist: ...
      for line in afile: ...
      for k, v in adict.items(): ...
```

```
No:   for key in adict.keys(): ...
      for line in afile.readlines(): ...
```

#### 2.9 Generators

Use generators as needed.

##### 2.9.1 Definition

A generator function returns an iterator that yields a value each time it executes a yield statement. After it yields a
value, the runtime state of the generator function is suspended until the next value is needed.

##### 2.9.2 Decision

Fine. Use “Yields:” rather than “Returns:” in the docstring for generator functions.

If the generator manages an expensive resource, make sure to force the clean up.

A good way to do the clean up is by wrapping the generator with a context manager PEP-0533.

#### 2.10 Lambda Functions

Okay for one-liners. Prefer generator expressions over map() or filter() with a lambda.

##### 2.10.1 Definition

Lambdas define anonymous functions in an expression, as opposed to a statement.

##### 2.10.2 Decision

Lambdas are allowed. If the code inside the lambda function spans multiple lines or is longer than 60-80 chars, it might be better to define it as a regular. For common operations like multiplication, use the functions from the operator module instead of lambda functions. For example, prefer operator.mul to lambda x, y: x * y.

#### 2.11 Conditional Expressions

Okay for simple cases.

##### 2.11.1 Definition

Conditional expressions (sometimes called a “ternary operator”) are mechanisms that provide a shorter syntax for if statements. For example: x = 1 if cond else 2.

##### 2.11.2 Decision

Okay to use for simple cases. Each portion must fit on one line: true-expression, if-expression, else-expression. Use a complete if statement when things get more complicated.

```
Yes:
    one_line = 'yes' if predicate(value) else 'no'
    slightly_split = ('yes' if predicate(value)
                      else 'no, nein, nyet')
    the_longest_ternary_style_that_can_be_done = (
        'yes, true, affirmative, confirmed, correct'
        if predicate(value)
        else 'no, false, negative, nay')
```

```
No:
    bad_line_breaking = ('yes' if predicate(value) else
                         'no')
    portion_too_long = ('yes'
                        if some_long_module.some_long_predicate_function(
                            really_long_variable_name)
                        else 'no, false, negative, nay')
```

####  2.12 Default Argument Values

Okay in most cases.

##### 2.12.1 Definition

You can specify values for variables at the end of a functionʼs parameter list, e.g., def foo(a, b=0):. If foo is called with only one argument, b is set to 0. If it is called with two arguments, b has the value of the second argument.

##### 2.12.2 Decision

Okay to use with the following caveat:

Do not use mutable objects as default values in the function or method definition.

```
Yes: def foo(a, b=None):
         if b is None:
             b = []
Yes: def foo(a, b: Sequence | None = None):
         if b is None:
             b = []
Yes: def foo(a, b: Sequence = ()):  # Empty tuple OK since tuples are immutable.
         ...
```

```
from absl import flags
_FOO = flags.DEFINE_string(...)
No:  def foo(a, b=[]):
         ...
No:  def foo(a, b=time.time()):  # Is `b` supposed to represent when this module was loaded?
         ...
No:  def foo(a, b=_FOO.value):  # sys.argv has not yet been parsed...
         ...
No:  def foo(a, b: Mapping = {}):  # Could still get passed to unchecked code.
         ...
```

#### 2.13 Properties

Properties may be used to control getting or setting attributes that require trivial computations or logic. Property
implementations must match the general expectations of regular attribute access: that they are cheap, straightforward,
and unsurprising.

##### 2.13.1 Definition

A way to wrap method calls for getting and setting an attribute as a standard attribute access.

##### 2.13.2 Decision

Properties are allowed, but, like operator overloading, should only be used when necessary and match the expectations of typical attribute access; follow the getter and setters rules otherwise.

For example, using a property to simply both get and set an internal attribute isnʼt allowed: there is no computation occurring, so the property is unnecessary. In comparison, using a property to
control attribute access or to calculate a trivially derived value is allowed: the logic is simple and unsurprising.

Properties should be created with the @property. Manually implementing a property descriptor is considered a power feature.

Inheritance with properties can be non-obvious. Do not use properties to implement computations a subclass may ever want to override and extend.

#### 2.14 True/False Evaluations

Use the “implicit” false if at all possible (with a few caveats).

##### 2.14.1 Definition

Python evaluates certain values as False when in a boolean context. A quick “rule of thumb” is that all “empty” values are considered false, so 0, None, [], {}, '' all evaluate as false in a boolean context.

##### 2.14.2 Decision

Use the “implicit” false if possible, e.g., if foo: rather than if foo != []:. There are a few caveats that you should keep in mind though:

- Always use if foo is None: (or is not None) to check for a None value. E.g., when testing whether a variable or argument that defaults to None was set to some other value. The other value might be a value thatʼs false in a boolean context!
- Never compare a boolean variable to False using ==. Use if not x: instead. If you need to distinguish False from None then chain the expressions, such as if not x and x is not None:.
- For sequences (strings, lists, tuples), use the fact that empty sequences are false, so if seq: and if not seq: are preferable to if len(seq): and if not len(seq): respectively.
- When handling integers, implicit false may involve more risk than benefit (i.e., accidentally handling None as 0). You may compare a value which is known to be an integer (and is not the result of len()) against the integer 0.

```
Yes: if not users:
         print('no users')
     if i % 10 == 0:
         self.handle_multiple_of_ten()
     def f(x=None):
         if x is None:
             x = []
```

```
No:  if len(users) == 0:
         print('no users')
     if not i % 10:
         self.handle_multiple_of_ten()
     def f(x=None):
         x = x or []

```