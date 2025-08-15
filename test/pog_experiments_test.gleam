import generated/database
import generated/models/post.{Post}
import generated/models/user.{User}
import generated/repositories/user_repository
import gleam/option.{None, Some}
import gleeunit/should

// Test that our generated model types can be constructed correctly
pub fn user_model_creation_test() {
  let insert_user =
    user.InsertUser(
      name: "example",
      email: "example@mail.com",
      description: None,
      age: 28,
    )
  case database.start_database() {
    Ok(db) -> {
      case user_repository.create_user(db, insert_user) {
        Ok(sql_user) -> {
          should.equal(insert_user.name, sql_user.name)
          should.equal(insert_user.email, sql_user.email)
          should.equal(insert_user.description, sql_user.description)
        }
        Error(err) -> {
          echo err
          Nil
        }
      }
    }
    Error(_) -> {
      todo
    }
  }
}
