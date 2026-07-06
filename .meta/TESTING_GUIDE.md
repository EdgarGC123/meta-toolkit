# Testing Structure Guide

**Purpose**: Guide for when and how to include testing infrastructure in generated toolkits.

**Key Principle**: Testing is OPTIONAL and CONDITIONAL. Only include if the toolkit involves code that needs testing.

---

## When to Include Testing

### Include testing structure when:
- ✅ Toolkit generates or processes code
- ✅ Toolkit has plugins with code implementations (processor.py)
- ✅ User explicitly requests testing infrastructure
- ✅ Workflow involves code validation or quality checks

### Do NOT include testing when:
- ❌ Toolkit is pure documentation/analysis (no code)
- ❌ Toolkit is for email composition or content creation
- ❌ Toolkit processes data but doesn't generate code
- ❌ User says "no" to testing question in toolkit generation

---

## Testing Structure by Language/Framework

### Python (pytest)
```
tests/
├── README.md                      # How to run tests
├── conftest.py                    # Pytest configuration
├── test_example.py                # Example test file
└── requirements-test.txt          # Testing dependencies
```

**Contents**:

**tests/README.md**:
```markdown
# Testing

## Setup

\```bash
pip install -r requirements-test.txt
\```

## Run Tests

\```bash
# Run all tests
pytest

# Run with coverage
pytest --cov

# Run specific test
pytest tests/test_example.py
\```

## Writing Tests

See `test_example.py` for template.
```

**tests/conftest.py**:
```python
import pytest

@pytest.fixture
def sample_data():
    """Example fixture providing test data."""
    return {"key": "value"}
```

**tests/test_example.py**:
```python
def test_example():
    """Example test - replace with actual tests."""
    assert True

def test_with_fixture(sample_data):
    """Example test using fixture."""
    assert "key" in sample_data
```

---

### JavaScript/TypeScript (Jest)
```
tests/
├── README.md                      # How to run tests
├── jest.config.js                 # Jest configuration
└── example.test.ts                # Example test file
```

**tests/jest.config.js**:
```javascript
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  roots: ['<rootDir>/tests'],
  testMatch: ['**/*.test.ts'],
};
```

**tests/example.test.ts**:
```typescript
describe('Example Test Suite', () => {
  it('should pass', () => {
    expect(true).toBe(true);
  });
});
```

---

### C# (.NET)
```
tests/
├── README.md                      # How to run tests
├── [ProjectName].Tests.csproj     # Test project file
└── ExampleTests.cs                # Example test file
```

**tests/ExampleTests.cs**:
```csharp
using Xunit;

namespace ProjectName.Tests
{
    public class ExampleTests
    {
        [Fact]
        public void ExampleTest_ShouldPass()
        {
            Assert.True(true);
        }
    }
}
```

---

### Java (JUnit)
```
tests/
├── README.md                      # How to run tests
└── ExampleTest.java               # Example test file
```

**tests/ExampleTest.java**:
```java
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

public class ExampleTest {
    @Test
    public void exampleTest() {
        assertTrue(true);
    }
}
```

---

## When Testing Can Be Deleted

The tests/ directory should be:
1. **Generated conditionally** during toolkit generation (only if user says "yes" to testing)
2. **Clearly marked as optional** in generated toolkit README
3. **Easily deletable** if user changes their mind

**In generated toolkit README, include**:
```markdown
## Testing (Optional)

This toolkit includes a testing structure in `tests/`. If you don't need it:

\```bash
rm -rf tests/
\```

The toolkit will function normally without the testing infrastructure.
```

---

## Advanced: Testing for Non-Code Toolkits

Even non-code toolkits might benefit from validation tests:

### Example: Documentation Toolkit Validation
```
tests/
├── README.md
└── validate_output.py             # Validates generated docs
```

**validate_output.py**:
```python
"""Validate generated documentation meets requirements."""
import os
from pathlib import Path

def test_all_sections_present():
    """Check all required sections exist."""
    doc_path = Path("outputs/documentation.md")
    content = doc_path.read_text()
    
    required_sections = [
        "# Executive Summary",
        "## Key Findings",
        "## Recommendations"
    ]
    
    for section in required_sections:
        assert section in content, f"Missing section: {section}"

def test_citations_valid():
    """Check all citations reference actual sources."""
    # Implementation depends on citation format
    pass
```

**When to use**: When output quality is critical and can be programmatically validated.

---

## Generation Integration

### Discovery Questions (Block A in `/start-here` PHASES.md)

When code involvement is confirmed, the generation skill asks:

```
Will this toolkit include code that needs testing?

If yes:
- Which test framework? (pytest / Jest / xUnit / JUnit / other)
- Where do tests live relative to source?
- Unit only, or also integration / E2E?
```

If the answer is "not sure yet" — defer as stub. The stub will reference this guide and surface the same questions when the user is ready.

### What Gets Generated (when confirmed)

Framework-specific structure:
- **pytest**: `tests/conftest.py`, `tests/test_example.py`, `tests/requirements-test.txt`
- **Jest/TypeScript**: `tests/jest.config.js`, `tests/example.test.ts`
- **xUnit (.NET)**: `tests/ExampleTests.cs`
- **JUnit**: `tests/ExampleTest.java`
- **Generic/unknown**: `tests/README.md` with setup instructions

### Deferred Stub Content

When testing is deferred, `.deferred/testing.md` is created with:
- What would be built (framework-specific test scaffolding)
- Questions to answer first (framework, test organization, coverage threshold)
- How to expand (describe the need, run `/research` for patterns, generate)
```

---

## Best Practices

### 1. Keep Test Structure Minimal
Generate only what's needed to get started. Users can expand as needed.

### 2. Provide Clear Examples
Example tests should demonstrate:
- How to structure test files
- How to use fixtures/setup
- Common assertion patterns

### 3. Document Dependencies
List all testing dependencies clearly (requirements-test.txt, package.json, etc.)

### 4. Make It Optional
Always make clear that testing infrastructure is optional and can be removed.

### 5. Don't Over-Generate
Don't try to generate actual tests for user's code - just provide the structure and examples.

---

## Decision Tree

```
User describes toolkit
    |
    v
Does description mention code/programming?
    |
    ├─ No → Skip testing questions
    |       Testing structure not generated
    |
    └─ Yes → Ask: "Will this toolkit include code that needs testing?"
            |
            ├─ No → Skip
            |       Testing structure not generated
            |
            └─ Yes → Ask: "Which testing framework?"
                    |
                    └─ Generate framework-specific structure
                        |
                        └─ Structure remains in generated toolkit
```

---

## Summary

**Testing infrastructure should be**:
- ✅ Conditional (only if toolkit involves code)
- ✅ Optional (easily removable)
- ✅ Minimal (basic structure + examples)
- ✅ Framework-specific (matches user's language choice)
- ✅ Well-documented (clear instructions to run)

**Testing infrastructure should NOT be**:
- ❌ Forced on all toolkits
- ❌ Generated for non-code workflows
- ❌ Complex or opinionated
- ❌ Tightly coupled to toolkit (should be deletable)

---

**Version**: 1.0  
**Last Updated**: 2026-05-22  
**Purpose**: Guide testing structure generation in toolkit generation
