# Payroll Smart Contract

This smart contract implements a blockchain-based payroll system with vesting schedules on the Stacks blockchain. It allows employers to manage employee compensation, vesting schedules, and bonus payments using STX tokens.

## Features

- **Vesting Schedule Management**: Set up customized vesting schedules for employees
- **Automated Claiming**: Employees can claim their vested tokens based on time elapsed
- **Bonus Distribution**: Employers can grant one-time bonuses to employees
- **Employee Status Management**: Ability to deactivate employees when they leave

## Contract Functions

### `add-employee`
```clarity
(add-employee (employee principal) (start-time uint) (end-time uint) (total-amount uint))
```
Adds a new employee with their vesting schedule.
- `employee`: Employee's principal address
- `start-time`: Vesting start time
- `end-time`: Vesting end time
- `total-amount`: Total STX amount to vest

### `claim`
```clarity
(claim)
```
Allows employees to claim their vested tokens based on the elapsed time.

### `deactivate-employee`
```clarity
(deactivate-employee (employee principal))
```
Deactivates an employee's vesting schedule.

### `grant-bonus`
```clarity
(grant-bonus (employee principal) (amount uint))
```
Grants a one-time bonus payment to an employee.

## Error Codes

- `ERR_UNAUTHORIZED (u100)`: Caller not authorized
- `ERR_INVALID_TIME (u101)`: Invalid time parameters
- `ERR_INVALID_AMOUNT (u102)`: Invalid amount specified
- `ERR_NOT_ACTIVE (u200)`: Employee not active
- `ERR_NOTHING_TO_CLAIM (u201)`: No tokens available to claim
- `ERR_EMPLOYEE_NOT_FOUND (u202)`: Employee not found

## Usage

1. Deploy the contract
2. Set the employer address
3. Add employees with their vesting schedules
4. Employees can claim their vested tokens
5. Employer can grant bonuses or deactivate employees as needed

## Security Considerations

- Only the designated employer can add/deactivate employees and grant bonuses
- Vesting schedule parameters are validated upon creation
- Claims are automatically calculated based on elapsed time
- Employee status is checked before processing claims


## Testing

Test the contract using Clarinet:
```bash
clarinet test
```

