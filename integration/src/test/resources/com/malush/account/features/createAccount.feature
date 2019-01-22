Feature: Create account
  As an existing user of the system
  I want to be able to create an account

  Background:
    Given the user is logged in


  Scenario: Create new account
    Given the user inserts account details: "Ivan Malusev" and "EUR"
    When the user tries to create a new account
    Then the new account is successfully created

  Scenario Outline: Missing or empty fields
    Given the user inserts account details: '<nameOnAccount>' and '<currencyId>'
    When the user tries to create a new account
    Then the account creation fails with Bad Request response
    Examples:
      |nameOnAccount|currencyId |
      |null         |EUR        |
      |             |EUR        |
      |Ivan Malusev |null       |
      |Ivan Malusev |           |
      |null         |null       |
      |             |           |

  Scenario: Missing token
    When the user tries to create a new account without providing access token
    Then the access to account resource is forbidden

  Scenario: Invalid token
    When the user tries to create a new account but provides an invalid token
    Then the access to account resource is forbidden

  Scenario Outline: Account exists
    Given the account with account details: '<nameOnAccount>' and '<currencyId>' already exists
    And the user inserts account details: '<nameOnAccount>' and '<currencyId>'
    When the user tries to create a new account
    Then the account creation fails with the response indicating the conflict
    Examples:
      |nameOnAccount|currencyId |
      |Ivan Malusev |EUR        |

  Scenario: Invalid currency
    Given the user inserts account details: 'Ivan Malusev' and 'XYZ'
    When the user tries to create a new account
    Then the account creation fails with Bad Request response

  Scenario Outline: Multiple currencies on one account
    Given the account with account details: '<nameOnAccount>' and '<currencyId1>' already exists
    And the user inserts account details: '<nameOnAccount>' and '<currencyId2>'
    When the user tries to create a new account
    Then the account creation fails with the response indicating the conflict
    Examples:
      |nameOnAccount|currencyId1 |currencyId2 |
      |Ivan Malusev |EUR         |RSD         |

  # It appears that the software currently has a bug since CurrencyValidator should allow only EUR but
  # validator accepts any non empty currency and uses Currency.getInstance to get an instance of it
  # if it's a valid iso4217 code.
  # In order to fix the issue we need to change the following line from the following class:
  # Class: radu-solution/src/main/java/com/mine/payment/validator/CurrencyValidator.java
  # Line 22: should change from: if(!StringUtils.isBlank(value) || "EUR".equals(value))
  # to if(!StringUtils.isBlank(value) && "EUR".equals(value))
  # as the line 22 doesn't make any sense. It will always be true for any non empty value
  Scenario Outline: Supported currencies
    When the user tries to add a new account for one of the supported currencies: '<supportedCurrency>'
    Then the new account is successfully created
    Examples:
      |supportedCurrency|
      |EUR              |
      #|RSD              |
      #Currently all currencies are supported (for example, just uncomment the line above and this
      #scenario will still not fail although it should).
      #After the issue is fixed this should only work for EUR but for any other currency it would fail