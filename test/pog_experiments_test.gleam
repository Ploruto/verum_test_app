import generated/database
import generated/models/post.{Post}
import generated/models/user.{User}
import generated/repositories/user_repository
import gleam/option.{None, Some}
import gleeunit/should

// Test that our generated model types can be constructed correctly
pub fn user_model_creation_test() {
  let test_user =
    User(
      id: 1,
      name: "Test User",
      email: "test@example.com",
      bio: Some("A test user bio"),
      created_at: 1_640_995_200,
      updated_at: 1_640_995_200,
    )

  case database.start_database() {
    Ok(db) -> {
      case user_repository.create_user(db, test_user) {
        Ok(sql_user) -> {
          should.equal(test_user.name, sql_user.name)
          should.equal(test_user.email, sql_user.email)
          should.equal(test_user.bio, sql_user.bio)
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

pub fn post_model_creation_test() {
  let test_post =
    Post(
      id: "550e8400-e29b-41d4-a716-446655440000",
      title: "Test Post Title",
      content: Some("This is test content"),
      published: True,
      user_id: "550e8400-e29b-41d4-a716-446655440001",
      created_at: 1_640_995_200,
      updated_at: 1_640_995_200,
    )

  should.equal(test_post.title, "Test Post Title")
  should.equal(test_post.content, Some("This is test content"))
  should.equal(test_post.published, True)
}

// Test that user partial update helpers work correctly
pub fn user_partial_update_helpers_test() {
  let partial =
    user.empty_partial_user()
    |> user.with_name("Updated Name")
    |> user.with_bio(Some("Updated bio"))

  should.equal(partial.name, Some("Updated Name"))
  should.equal(partial.bio, Some(Some("Updated bio")))
  should.equal(partial.email, None)
}

// Test that post partial update helpers work correctly  
pub fn post_partial_update_helpers_test() {
  let partial =
    post.empty_partial_post()
    |> post.with_title("Updated Title")
    |> post.with_published(False)

  should.equal(partial.title, Some("Updated Title"))
  should.equal(partial.published, Some(False))
  should.equal(partial.content, None)
}
