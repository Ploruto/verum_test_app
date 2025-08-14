import gleam/option.{type Option, None, Some}
import gleam/time/calendar.{type Date, type TimeOfDay}
import gleam/time/timestamp.{type Timestamp}
import gleam/dynamic.{type Dynamic}

pub type User {
  User(
    id: String,
    name: String,
    email: String,
    bio: Option(String),
    created_at: Int,
    updated_at: Int,
  )
}

pub type UserField {
  Id
  Name
  Email
  Bio
  CreatedAt
  UpdatedAt
}

/// Partial User for updates
pub type PartialUser {
  PartialUser(
  name: Option(String),
  email: Option(String),
  bio: Option(Option(String))
  )
}

/// Create empty partial user for updates
pub fn empty_partial_user() -> PartialUser {
  PartialUser(name: None, email: None, bio: None)
}

/// Create partial user from existing user
pub fn from_user(user: User) -> PartialUser {
  PartialUser(
    name: Some(user.name),
    email: Some(user.email),
    bio: Some(user.bio)
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

/// Set bio in partial user
pub fn with_bio(partial: PartialUser, bio: Option(String)) -> PartialUser {
  PartialUser(..partial, bio: Some(bio))
}