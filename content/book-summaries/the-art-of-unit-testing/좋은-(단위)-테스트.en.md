---
version: "1"
note:
created_date: 2025-12-19T10:52:00
translator: Claude Haiku 4.5
---

## Table of Contents
- [[#1. Characteristics of Good Unit Tests]]
- [[#2. How to Write Good Tests]]
- [[#3. Unit Testing Checklist]]
- [[#4. Test Failure Response Process]]

---

## 1. Characteristics of Good Unit Tests

### 1.1 Core Attributes (Ch.1, pp.15-16)

**Attributes all good automated tests should have:**
- **Clear Intent**: The test writer's intention must be clear
- **Easy to Read and Write**: Code is concise and intuitive
- **Automated**: Can be executed with a single button
- **Consistent Results**: Always returns the same result without code changes
- **Useful and Actionable Results**: Provides clear information when it fails
- **Runnable by Anyone**: Easy for any team member to execute
- **Easy to Debug on Failure**: Easy to identify expected vs. actual values

**Additional attributes specific to good unit tests:**
- **Fast Execution Speed**
- **Complete Control**: Completely control the code being tested
- **Complete Isolation**: Runs independently from other tests
- **In-Memory Execution**: No need for file system, network, or database
- **Synchronous/Linear Execution**: Multithread usage excluded as much as possible

### 1.2 Trust Criteria (Ch.7, pp.150-151)

**Trustworthy tests:**
- ✅ When it fails, you worry about a real bug
- ✅ When it passes, you feel confident and no manual testing is needed

**Untrustworthy tests:**
- ❌ Even when it fails, you think it's a false positive
- ❌ Even when it passes, you manually test "just to be safe"

---

## 2. How to Write Good Tests

### 2.1 Entry Points and Exit Points (Ch.1, pp.6-11)

**Concept:**
- **Entry Point**: The starting point of a unit of work (function call)
- **Exit Points**: The results of a unit of work
  - Return value (return value)
  - State change (state change)
  - Third-party call (third-party call)

**JavaScript Example:**
```javascript
// Function with 3 exit points
let total = 0;

const sum = (numbers) => {
  const [a, b] = numbers.split(',');

  // Exit Point 1: Third-party call
  logger.info('calculation', { firstNumWas: a, secondNumWas: b });

  const result = parseInt(a) + parseInt(b);

  // Exit Point 2: State change
  total += result;

  // Exit Point 3: Return value
  return result;
};
```

**Python Version:**
```python
# Function with 3 exit points
total = 0

def sum_numbers(numbers: str) -> int:
    a, b = numbers.split(',')

    # Exit Point 1: Third-party call
    logger.info('calculation', {'firstNumWas': a, 'secondNumWas': b})

    result = int(a) + int(b)

    # Exit Point 2: State change
    global total
    total += result

    # Exit Point 3: Return value
    return result
```

**Best Practice:**
> Write a separate test for each exit point (Ch.1, p.10)

---

### 2.2 Removing Logic from Tests (Ch.7, pp.153-156)

#### 2.2.1 Avoid Dynamic Expected Values

**❌ Anti-pattern: Logic in tests**

```javascript
// Bad example - Repeating production logic in test
it("returns correct greeting for name", () => {
  const name = "abc";
  const result = makeGreeting(name);
  expect(result).toBe("hello" + name);  // ❌ Repeating production logic
});
```

```python
# Bad example - Repeating production logic in test
def test_greeting_bad():
    name = "abc"
    result = make_greeting(name)
    assert result == "hello" + name  # ❌ Repeating production logic
```

**✅ Best Practice: Hardcoded expected values**

```javascript
// Good example - Verify with hardcoded values
it("returns correct greeting for name", () => {
  const result = makeGreeting("abc");
  expect(result).toBe("hello abc");  // ✅ Hardcoded value
});
```

```python
# Good example - Verify with hardcoded values
def test_greeting_good():
    result = make_greeting("abc")
    assert result == "hello abc"  # ✅ Hardcoded value
```

#### 2.2.2 Avoid Loops and Conditionals

**❌ Anti-pattern: Multiple scenarios in one test**

```javascript
// Bad example - Using loops and conditionals
it("correctly finds out if it is a name", () => {
  const namesToTest = ["firstOnly", "first second", ""];

  namesToTest.forEach((name) => {
    const result = isName(name);
    if (name.includes(" ")) {
      expect(result).toBe(true);
    } else {
      expect(result).toBe(false);
    }
  });
});
```

```python
# Bad example - Using loops and conditionals
def test_is_name_bad():
    names_to_test = ["firstOnly", "first second", ""]

    for name in names_to_test:
        result = is_name(name)
        if " " in name:
            assert result == True
        else:
            assert result == False
```

**✅ Best Practice: Separate tests by scenario**

```javascript
// Good example - Each scenario as a separate test
describe("isName", () => {
  it("returns true for full name", () => {
    const result = isName("first second");
    expect(result).toBe(true);
  });

  it("returns false for single word", () => {
    const result = isName("firstOnly");
    expect(result).toBe(false);
  });

  it("returns false for empty string", () => {
    const result = isName("");
    expect(result).toBe(false);
  });
});
```

```python
# Good example - Each scenario as a separate test
class TestIsName:
    def test_returns_true_for_full_name(self):
        result = is_name("first second")
        assert result == True

    def test_returns_false_for_single_word(self):
        result = is_name("firstOnly")
        assert result == False

    def test_returns_false_for_empty_string(self):
        result = is_name("")
        assert result == False
```

---

### 2.3 Writing Assertions (Ch.7, pp.158-160)

#### 2.3.1 Verify Only One Thing Per Test

**❌ Anti-pattern: Multiple concerns in one test**

```javascript
// Bad example - Verifying two concerns simultaneously
it("works", () => {
  const callback = jest.fn();
  const result = trigger(1, 2, callback);

  expect(result).toBe(3);  // Concern 1: Return value
  expect(callback).toHaveBeenCalledWith("I'm triggered");  // Concern 2: Callback invocation
});
```

```python
# Bad example - Verifying two concerns simultaneously
def test_works_bad():
    callback = Mock()
    result = trigger(1, 2, callback)

    assert result == 3  # Concern 1: Return value
    callback.assert_called_with("I'm triggered")  # Concern 2: Callback invocation
```

**✅ Best Practice: Separate tests by concern**

```javascript
// Good example - Each concern as a separate test
describe("trigger", () => {
  it("triggers a given callback", () => {
    const callback = jest.fn();
    trigger(1, 2, callback);
    expect(callback).toHaveBeenCalledWith("I'm triggered");
  });

  it("sums up given values", () => {
    const result = trigger(1, 2, jest.fn());
    expect(result).toBe(3);
  });
});
```

```python
# Good example - Each concern as a separate test
class TestTrigger:
    def test_triggers_callback(self):
        callback = Mock()
        trigger(1, 2, callback)
        callback.assert_called_with("I'm triggered")

    def test_sums_up_values(self):
        result = trigger(1, 2, Mock())
        assert result == 3
```

#### 2.3.2 Exception: Multiple Properties of a Single Concern

**✅ Allowed: Verifying multiple properties of the same concern** (Ch.7, p.160)

```javascript
// Allowed - Multiple properties of the same concern (person object creation)
it("creates person given passed in values", () => {
  const result = makePerson("name", 1);

  expect(result.name).toBe("name");
  expect(result.age).toBe(1);
  // Both check the single concern: "was the person object created correctly?"
});
```

```python
# Allowed - Multiple properties of the same concern
def test_creates_person():
    result = make_person("name", 1)

    assert result.name == "name"
    assert result.age == 1
    # Both check the single concern: "was the person object created correctly?"
```

---

### 2.4 Improving Maintainability (Ch.8)

#### 2.4.1 Handling API Changes with Factory Functions (Ch.8, pp.167-169)

**❌ Anti-pattern: Creating objects directly in tests**

```javascript
// Bad example - All tests must be modified when constructor signature changes
it("passes with zero rules", () => {
  const verifier = new PasswordVerifier([], { info: jest.fn() });
  const result = verifier.verify("any input");
  expect(result).toBe(true);
});

it("fails with one failing rule", () => {
  const verifier = new PasswordVerifier([() => false], { info: jest.fn() });
  const result = verifier.verify("any input");
  expect(result).toBe(false);
});
```

```python
# Bad example - All tests must be modified when constructor signature changes
def test_passes_with_zero_rules_bad():
    verifier = PasswordVerifier([], FakeLogger())
    result = verifier.verify("any input")
    assert result == True

def test_fails_with_one_failing_rule_bad():
    verifier = PasswordVerifier([lambda x: False], FakeLogger())
    result = verifier.verify("any input")
    assert result == False
```

**✅ Best Practice: Use factory functions**

```javascript
// Good example - Centralize creation logic with factory functions
const makeFakeLogger = () => {
  return { info: jest.fn() };
};

const makePasswordVerifier = (
  rules = [],
  fakeLogger = makeFakeLogger()
) => {
  return new PasswordVerifier(rules, fakeLogger);
};

it("passes with zero rules", () => {
  const verifier = makePasswordVerifier([]);
  const result = verifier.verify("any input");
  expect(result).toBe(true);
});

it("fails with one failing rule", () => {
  const verifier = makePasswordVerifier([() => false]);
  const result = verifier.verify("any input");
  expect(result).toBe(false);
});
```

```python
# Good example - Centralize creation logic with factory functions
def make_fake_logger():
    return FakeLogger()

def make_password_verifier(rules=None, fake_logger=None):
    if rules is None:
        rules = []
    if fake_logger is None:
        fake_logger = make_fake_logger()
    return PasswordVerifier(rules, fake_logger)

def test_passes_with_zero_rules_good():
    verifier = make_password_verifier([])
    result = verifier.verify("any input")
    assert result == True

def test_fails_with_one_failing_rule_good():
    verifier = make_password_verifier([lambda x: False])
    result = verifier.verify("any input")
    assert result == False
```

#### 2.4.2 Test Isolation (Ch.8, pp.169-173)

**❌ Anti-pattern: Test execution order dependencies**

```javascript
// Bad example - Tests depend on execution order
describe("loginUser", () => {
  test("no user, login fails", () => {
    // ❌ Assumes cache is empty (previous test not executed)
    const result = app.loginUser("a", "abc");
    expect(result).toBe(false);
  });

  test("adds user to cache", () => {
    getUserCache().addUser({ key: "a", password: "abc" });
  });

  test("user exists, login succeeds", () => {
    // ❌ Assumes previous test executed
    const result = app.loginUser("a", "abc");
    expect(result).toBe(true);
  });
});
```

```python
# Bad example - Tests depend on execution order
class TestLoginUserBad:
    def test_no_user_login_fails(self):
        # ❌ Assumes cache is empty
        result = app.login_user("a", "abc")
        assert result == False

    def test_adds_user_to_cache(self):
        get_user_cache().add_user({"key": "a", "password": "abc"})

    def test_user_exists_login_succeeds(self):
        # ❌ Assumes previous test executed
        result = app.login_user("a", "abc")
        assert result == True
```

**✅ Best Practice: Each test sets up what it needs**

```javascript
// Good example - Each test independently sets up what it needs
const addDefaultUser = () =>
  getUserCache().addUser({ key: "a", password: "abc" });

describe("loginUser", () => {
  beforeEach(() => getUserCache().reset());

  it("user exists, login succeeds", () => {
    addDefaultUser();  // ✅ Setup specific to this test
    const result = app.loginUser("a", "abc");
    expect(result).toBe(true);
  });

  it("user missing, login fails", () => {
    // ✅ No additional setup needed (cache is empty)
    const result = app.loginUser("a", "abc");
    expect(result).toBe(false);
  });
});
```

```python
# Good example - Each test independently sets up what it needs
class TestLoginUserGood:
    def setup_method(self):
        get_user_cache().reset()

    def add_default_user(self):
        get_user_cache().add_user({"key": "a", "password": "abc"})

    def test_user_exists_login_succeeds(self):
        self.add_default_user()  # ✅ Setup specific to this test
        result = app.login_user("a", "abc")
        assert result == True

    def test_user_missing_login_fails(self):
        # ✅ No additional setup needed
        result = app.login_user("a", "abc")
        assert result == False
```

#### 2.4.3 Avoiding Overspecification (Ch.8, pp.177-183)

##### Anti-pattern 1: Verifying Internal Methods

**❌ Bad Example: Verifying protected method calls**

```javascript
// Bad example - Testing internal implementation
test("checkFailedRules is called", () => {
  const pv = new PasswordVerifier([], fakeLogger);
  const failedMock = jest.fn(() => []);

  pv["findFailedRules"] = failedMock;  // ❌ Mocking internal method
  pv.verify("abc");

  expect(failedMock).toHaveBeenCalled();  // ❌ Verifying internal call
});
```

```python
# Bad example - Testing internal implementation
def test_check_failed_rules_called_bad():
    pv = PasswordVerifier([], fake_logger)

    with patch.object(pv, '_find_failed_rules') as mock_find:
        mock_find.return_value = []
        pv.verify("abc")
        mock_find.assert_called()  # ❌ Verifying internal call
```

**✅ Good Example: Verify exit points only**

```javascript
// Good example - Testing public contract (return value)
test("verify with failing rule returns false", () => {
  const pv = new PasswordVerifier([() => false], fakeLogger);
  const result = pv.verify("abc");

  expect(result).toBe(false);  // ✅ Verify return value (exit point)
});
```

```python
# Good example - Testing public contract (return value)
def test_verify_with_failing_rule():
    pv = PasswordVerifier([lambda x: False], fake_logger)
    result = pv.verify("abc")

    assert result == False  # ✅ Verify return value (exit point)
```

##### Anti-pattern 2: Over-verifying Order and Structure

**❌ Bad Example: Verify everything**

```javascript
// Bad example - Verify order, structure, and values
test("overspecify order and schema", () => {
  const pv = new PasswordVerifier([input => input.includes("abc")]);
  const results = pv.verify(["a", "ab", "abc", "abcd"]);

  expect(results).toEqual([
    { input: "a", result: false },
    { input: "ab", result: false },
    { input: "abc", result: true },
    { input: "abcd", result: true },
  ]);
  // ❌ Test breaks if order changes or properties are added
});
```

```python
# Bad example - Verify order, structure, and values
def test_overspecify_bad():
    pv = PasswordVerifier([lambda x: "abc" in x])
    results = pv.verify(["a", "ab", "abc", "abcd"])

    assert results == [
        {"input": "a", "result": False},
        {"input": "ab", "result": False},
        {"input": "abc", "result": True},
        {"input": "abcd", "result": True},
    ]
    # ❌ Test breaks if order changes or properties are added
```

**✅ Good Example: Verify only what matters**

```javascript
// Good example - Ignore order and schema, verify logic only
test("ignore order and schema", () => {
  const pv = new PasswordVerifier([input => input.includes("abc")]);
  const results = pv.verify(["a", "ab", "abc", "abcd"]);

  const findResultFor = (input) =>
    results.find(r => r.input === input).result;

  expect(results.length).toBe(4);
  expect(findResultFor("a")).toBe(false);
  expect(findResultFor("abc")).toBe(true);
  // ✅ Test passes even if order changes
});
```

```python
# Good example - Ignore order and schema, verify logic only
def test_ignore_order_and_schema_good():
    pv = PasswordVerifier([lambda x: "abc" in x])
    results = pv.verify(["a", "ab", "abc", "abcd"])

    def find_result_for(input_val):
        return next(r for r in results if r["input"] == input_val)["result"]

    assert len(results) == 4
    assert find_result_for("a") == False
    assert find_result_for("abc") == True
    # ✅ Test passes even if order changes
```

##### Anti-pattern 3: Exact String Matching

**❌ Bad Example: Exact string match**

```javascript
// Bad example - Exact string matching
test("over specify string", () => {
  const pv = new PasswordVerifier([input => input.includes("abc")]);
  pv.verify(["a", "ab", "abc", "abcd"]);
  const msg = pv.getMsg();

  expect(msg).toBe("you have 2 failed rules.");
  // ❌ Test breaks if punctuation, capitalization, or wording changes
});
```

```python
# Bad example - Exact string matching
def test_over_specify_string_bad():
    pv = PasswordVerifier([lambda x: "abc" in x])
    pv.verify(["a", "ab", "abc", "abcd"])
    msg = pv.get_msg()

    assert msg == "you have 2 failed rules."
    # ❌ Test breaks if punctuation, capitalization, or wording changes
```

**✅ Good Example: Verify key content only**

```javascript
// Good example - Check that key content is included
test("more future proof string checking", () => {
  const pv = new PasswordVerifier([input => input.includes("abc")]);
  pv.verify(["a", "ab", "abc", "abcd"]);
  const msg = pv.getMsg();

  expect(msg).toMatch(/2 failed/);
  // ✅ Test passes even if wording slightly changes
});
```

```python
# Good example - Check that key content is included
def test_more_future_proof_string_good():
    pv = PasswordVerifier([lambda x: "abc" in x])
    pv.verify(["a", "ab", "abc", "abcd"])
    msg = pv.get_msg()

    assert "2 failed" in msg
    # ✅ Test passes even if wording slightly changes
```

---

### 2.5 Improving Readability (Ch.9)

#### 2.5.1 Test Naming (Ch.9, pp.188-189)

**Three Required Pieces of Information:** (Ch.9, p.188)
1. **Entry Point** - What are we testing?
2. **Scenario** - Under what conditions?
3. **Expected Behavior** - What should it do?

**JavaScript Example:**
```javascript
// ✅ Good example - Contains all information
test('verifyPassword, with a failing rule, returns error based on rule.reason', () => {
  // Entry Point: verifyPassword
  // Scenario: with a failing rule
  // Expected Behavior: returns error based on rule.reason
});

// ✅ Or use nested describe
describe('verifyPassword', () => {
  describe('with a failing rule', () => {
    it('returns error based on the rule.reason', () => {
      // ...
    });
  });
});
```

**Python Version:**
```python
# ✅ Good example - Use nested classes for structure
class TestVerifyPassword:
    class TestWithFailingRule:
        def test_returns_error_based_on_rule_reason(self):
            # Entry Point: VerifyPassword
            # Scenario: WithFailingRule
            # Expected Behavior: returns_error_based_on_rule_reason
            pass

# ✅ Or express all information in function name
def test_verify_password_with_failing_rule_returns_error_based_on_rule_reason():
    # Entry Point: verify_password
    # Scenario: with_failing_rule
    # Expected Behavior: returns_error_based_on_rule_reason
    pass
```

**❌ Bad Examples - Missing Information:** (Ch.9, p.189)
```javascript
// ❌ Missing entry point
test('failing rule, returns error', () => { ... });

// ❌ Missing scenario
test('verifyPassword, returns error', () => { ... });

// ❌ Missing expected behavior
test('verifyPassword, with failing rule', () => { ... });
```

```python
# ❌ Missing entry point
def test_failing_rule_returns_error():
    pass

# ❌ Missing scenario
def test_verify_password_returns_error():
    pass

# ❌ Missing expected behavior
def test_verify_password_with_failing_rule():
    pass
```

#### 2.5.2 Remove Magic Values (Ch.9, pp.189-190)

**❌ Anti-pattern: Using magic values**

```javascript
// Bad example - Values with unclear meaning
test('on weekends, throws exceptions', () => {
  expect(() => verifyPassword('jhGGu78!', [], 0))
    .toThrowError("It's the weekend!");
  // What is 'jhGGu78!'? What is []? What is 0?
});
```

```python
# Bad example - Values with unclear meaning
def test_weekend_throws_bad():
    with pytest.raises(Exception, match="It's the weekend!"):
        verify_password('jhGGu78!', [], 0)
    # What is 'jhGGu78!'? What is []? What is 0?
```

**✅ Best Practice: Use meaningful variable names**

```javascript
// Good example - Clear meaning for each value
test("on weekends, throws exceptions", () => {
  const SUNDAY = 0;
  const NO_RULES = [];
  const ANY_PASSWORD = "anything";

  expect(() => verifyPassword(ANY_PASSWORD, NO_RULES, SUNDAY))
    .toThrowError("It's the weekend!");
});
```

```python
# Good example - Clear meaning for each value
def test_weekend_throws_good():
    SUNDAY = 0
    NO_RULES = []
    ANY_PASSWORD = "anything"

    with pytest.raises(Exception, match="It's the weekend!"):
        verify_password(ANY_PASSWORD, NO_RULES, SUNDAY)
```

#### 2.5.3 Separate Action and Assertion (Ch.9, pp.190-191)

**❌ Anti-pattern: Everything on one line**

```javascript
// Bad example - Hard to read and debug
expect(verifier.verify("any value")[0]).toContain("fake reason");
```

```python
# Bad example - Hard to read and debug
assert "fake reason" in verifier.verify("any value")[0]
```

**✅ Best Practice: Separate action from assertion**

```javascript
// Good example - Clear and easy to debug
const result = verifier.verify("any value");
expect(result[0]).toContain("fake reason");
```

```python
# Good example - Clear and easy to debug
result = verifier.verify("any value")
assert "fake reason" in result[0]
```

#### 2.5.4 Avoid Setup Functions (Ch.9, pp.191-193)

**❌ Anti-pattern: Setting up mocks in beforeEach**

```javascript
// Bad example - Must scroll to top to understand what mockLog is
describe("password verifier", () => {
  let mockLog;

  beforeEach(() => {
    mockLog = Substitute.for<IComplicatedLogger>();
  });

  test("verify calls logger with PASS", () => {
    const verifier = new PasswordVerifier([], mockLog);
    verifier.verify("anything");
    mockLog.received().info(
      Arg.is(x => x.includes("PASSED")),
      "verify"
    );
  });
});
```

```python
# Bad example - Must scroll to top to understand what mock_log is
class TestPasswordVerifier:
    def setup_method(self):
        self.mock_log = Mock()

    def test_verify_calls_logger_with_pass(self):
        verifier = PasswordVerifier([], self.mock_log)
        verifier.verify("anything")
        # Must find where mock_log comes from
```

**✅ Best Practice: Create inside test or use helper functions**

```javascript
// Good example 1 - Create directly inside test
test("verify calls logger with PASS", () => {
  const mockLog = Substitute.for<IComplicatedLogger>();
  const verifier = new PasswordVerifier([], mockLog);
  verifier.verify("anything");
  mockLog.received().info(
    Arg.is(x => x.includes("PASSED")),
    "verify"
  );
});

// Good example 2 - Use helper function
const makeMockLogger = () => Substitute.for<IComplicatedLogger>();

test("verify calls logger with PASS", () => {
  const mockLog = makeMockLogger();
  const verifier = new PasswordVerifier([], mockLog);
  verifier.verify("anything");
  mockLog.received().info(
    Arg.is(x => x.includes("PASSED")),
    "verify"
  );
});
```

```python
# Good example 1 - Create directly inside test
def test_verify_calls_logger_with_pass_good():
    mock_log = Mock()
    verifier = PasswordVerifier([], mock_log)
    verifier.verify("anything")
    mock_log.info.assert_called()

# Good example 2 - Use helper function
def make_mock_logger():
    return Mock()

def test_verify_calls_logger_with_pass_with_helper():
    mock_log = make_mock_logger()
    verifier = PasswordVerifier([], mock_log)
    verifier.verify("anything")
    mock_log.info.assert_called()
```

---

## 3. Unit Testing Checklist

### 3.1 Pre-Writing Checklist (Ch.1, pp.16-17)

You should be able to answer "yes" to all of these questions:

**Execution and Results:**
- [ ] Can you run a test you wrote weeks/months ago and get results?
- [ ] Can anyone on your team run your test and get results?
- [ ] Can you run all tests within minutes?
- [ ] Can you run all tests with the click of a button?

**Writing and Isolation:**
- [ ] Can you write a basic test within minutes?
- [ ] Will your tests still pass even if someone else's code has a bug?
- [ ] Do you get the same results on different machines or environments?
- [ ] Do your tests work without database, network, or deployment?
- [ ] Does deleting/moving/changing one test not affect others?

### 3.2 Trustworthiness Checklist (Ch.7, pp.150-164)

#### When a test fails:

**Identifying the cause:**
- [ ] Is the failure due to a real bug? (Ch.7, p.151)
- [ ] Is there a bug in the test itself? (Ch.7, pp.151-152)
  - [ ] Are you asserting the wrong thing?
  - [ ] Are you injecting wrong values into the entry point?
  - [ ] Are you calling the entry point incorrectly?
- [ ] Has the functionality changed making the test outdated? (Ch.7, p.152)
- [ ] Does it conflict with another test? (Ch.7, pp.152-153)
- [ ] Is the test flaky? (Ch.7, pp.153, 161-164)

#### When a test passes:

**Basic Validation:**
- [ ] Does the test have assertions? (Ch.7, p.157)
- [ ] Can you understand the test? (Ch.7, p.157)
- [ ] Is it mixed with flaky integration tests? (Ch.7, p.158)
- [ ] Are you verifying multiple concerns? (Ch.7, pp.158-160)
- [ ] Are you using dynamic values (time, random, etc.)? (Ch.7, pp.160-161)

**Logic Validation:**
- [ ] Does it have if/else or switch statements? (Ch.7, p.153)
- [ ] Does it have foreach, for, or while loops? (Ch.7, p.153)
- [ ] Does it have string concatenation (+)? (Ch.7, p.153)
- [ ] Does it have try/catch? (Ch.7, p.153)
- [ ] Are you creating dynamic expected values? (Ch.7, pp.153-155)

### 3.3 Maintainability Checklist (Ch.8)

**Handling API Changes:**
- [ ] Are you using factory functions? (Ch.8, pp.168-169)
- [ ] Do you only need to modify one place when the constructor changes?

**Test Isolation:**
- [ ] Does each test run independently? (Ch.8, pp.169-173)
- [ ] Do you reset shared resources using beforeEach/setup_method?
- [ ] Do your tests depend on execution order?

**Removing Duplication:**
- [ ] Do you follow DRY principle? (Ch.8, p.175)
- [ ] Are you using helper functions?
- [ ] Have you considered parameterized tests? (Ch.8, pp.176-177)

**Specification Level:**
- [ ] Are you testing private/protected methods? (Ch.8, pp.173-175)
- [ ] Are you testing the public contract instead of internal behavior? (Ch.8, pp.177-179)
- [ ] Are you over-verifying order or structure? (Ch.8, pp.179-181)
- [ ] Are you checking string inclusion instead of exact matches? (Ch.8, pp.181-183)

### 3.4 Readability Checklist (Ch.9)

**Naming:**
- [ ] Does the test name include the entry point? (Ch.9, p.188)
- [ ] Does the test name include the scenario? (Ch.9, p.188)
- [ ] Does the test name include the expected behavior? (Ch.9, p.188)

**Magic Values:**
- [ ] Are you using meaningful variable names? (Ch.9, pp.189-190)
- [ ] Are you avoiding direct number/string literals?

**Structure:**
- [ ] Are action and assertion separated? (Ch.9, pp.190-191)
- [ ] Are you using helper functions instead of setup methods? (Ch.9, pp.191-193)
- [ ] Is mock initialization inside the test? (Ch.9, pp.191-192)

---

## 4. Test Failure Response Process (Ch.7, pp.151-152)

```
1. Test Failure Detected
   ↓
2. Debug Production Code
   ↓
3. No Bug in Production Code?
   ↓ (Yes)
4. Debug Test Code
   ↓
5. Find and Fix Test Bug
   ↓
6. Run Test → Verify Pass
   ↓
7. Intentionally Insert Obvious Bug in Production
   ↓
8. Run Test → Verify Failure
   ↓
9. Remove Production Bug
   ↓
10. Run Test → Verify Pass
    ↓
11. Commit
```

**Core Principles:**
- Verify both when tests pass and when they fail
- This validates that tests are working correctly
- Using TDD (Test-Driven Development) makes this process automatic

---

## 5. Summary: Three Pillars of Good Tests

### 5.1 Trustworthiness (Ch.7, pp.149-164)
- Test results must be reliable
- When it fails: Confident you found a real bug
- When it passes: No manual testing needed

### 5.2 Maintainability (Ch.8, pp.165-187)
- Changes should be easy
- Minimal test modifications when production code changes
- Maintain independence between tests

### 5.3 Readability (Ch.9, pp.187-194)
- Intent must be clear
- Easy for anyone to understand
- Quick problem identification on failure

---

## References

This guide is based on the following book:

**The Art of Unit Testing, 3rd Edition** by Roy Osherove (Manning, 2024)
- Chapter 1: The basics of unit testing (pp.3-28)
- Chapter 7: Trustworthy tests (pp.149-165)
- Chapter 8: Maintainability (pp.165-187)
- Chapter 9: Readability (pp.187-194)
