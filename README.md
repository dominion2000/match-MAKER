# Match-MAKER Clarity Contract

## Overview

**Match-MAKER** is a simple 1v1 pairing smart contract for the Stacks blockchain, written in Clarity. It allows users to join matchmaking queues by tag, automatically pairs users, and stores match data with incremental IDs. The contract is designed to be readable, minimal, and compatible with [Clarinet](https://github.com/clarinet/clarinet) for local development and testing.

## Features

- **Tag-based matchmaking:** Players join a queue for a specific tag.
- **Instant pairing:** The first player waits, the second player is instantly matched.
- **Match storage:** All matches are stored with unique, incremental IDs.
- **Leave queue:** Players can leave the waiting queue if they are the waiting player.
- **Error codes:** Standardized error codes for common failure cases.

## Contract Structure

- `waiting` map: Tracks waiting players per tag.
- `matches` map: Stores completed matches with details.
- `match-count` data var: Keeps track of the next match ID.

## Public Functions

- `join(tag)`: Join matchmaking for a tag. Returns match ID if paired, or `u0` if waiting.
- `leave(tag)`: Leave matchmaking if you are the waiting player. Returns `(ok true)` on success.

## Read-Only Functions

- `get-waiting(tag)`: Returns the principal of the waiting player for a tag.
- `get-match(id)`: Returns match details for a given match ID.
- `get-match-count()`: Returns the current match count.

## Error Codes

- `u300`: Already waiting for the same tag.
- `u301`: Not waiting or unauthorized leave.
- `u303`: Match not found.

## Usage

Deploy this contract to the Stacks blockchain using [Clarinet](https://github.com/clarinet/clarinet) or your preferred deployment tool.

### Example: Joining a Match

```clarity
(contract-call? .match-MAKER join "chess")
