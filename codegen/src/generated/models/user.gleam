import gleam/option.{type Option, None, Some}
import gleam/time/calendar.{type Date, type TimeOfDay}
import gleam/time/timestamp.{type Timestamp}
import gleam/dynamic.{type Dynamic}

pub type User {
  User(
    id: Int,
    name: String,
    email: String,
    description: Option(String),
    created_at: Int,
    updated_at: Int,
    age: Int,
  )
}

pub type UserField {
  Id
  Name
  Email
  Description
  CreatedAt
  UpdatedAt
  Age
}

/// Partial User for updates
pub type PartialUser {
  PartialUser(
  name: Option(String),
  email: Option(String),
  description: Option(Option(String)),
  age: Option(Int)
  )
}

/// Create empty partial user for updates
pub fn empty_partial_user() -> PartialUser {
  PartialUser(name: None, email: None, description: None, age: None)
}

/// Create partial user from existing user
pub fn from_user(user: User) -> PartialUser {
  PartialUser(
    name: Some(user.name),
    email: Some(user.email),
    description: Some(user.description),
    age: Some(user.age)
  )
}

/// Set name in partial user
pub fn with_name(partial: PartialUser, name: String) -> PartialUser {
  PartialUser(..partial, name: Some(name))
}

/// Set email in partial user
pub fn with_email(partial: PartialUser, email: String) -> PartialUser {
  PartialUser(..partial, email: Some(email))
}

/// Set description in partial user
pub fn with_description(partial: PartialUser, description: Option(String)) -> PartialUser {
  PartialUser(..partial, description: Some(description))
}

/// Set age in partial user
pub fn with_age(partial: PartialUser, age: Int) -> PartialUser {
  PartialUser(..partial, age: Some(age))
}