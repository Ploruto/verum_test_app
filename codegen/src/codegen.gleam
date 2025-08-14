import gleam/io
import gleam/option.{None}
import verum/core/app_spec
import verum/core/field_builder as field
import verum/core/generator
import verum/core/migrations
import verum/core/model.{
  DateTime, Field, Model, NotNull, PrimaryKey, String, Unique,
}

pub fn main() -> Nil {
  io.println("🔧 Generating code for test_app...")

  let user_model =
    model.new_model(
      name: "user",
      table_name: "users",
      fields: [
        field.new()
          |> field.with_name("id")
          |> field.with_data_type(model.Int)
          |> field.as_primary_key()
          |> field.with_constraints([model.NotNull]),
        field.new()
          |> field.with_name("name")
          |> field.with_data_type(model.String(100))
          |> field.with_constraints([model.NotNull])
          |> field.with_validation_rules([model.MinLength(2)]),
        field.new()
          |> field.with_name("email")
          |> field.with_data_type(model.String(255))
          |> field.with_constraints([model.NotNull, model.Unique])
          |> field.with_validation_rules([model.ValidEmail]),
        field.new()
          |> field.with_name("bio")
          |> field.with_data_type(model.Text),
      ],
      relationships: [],
    )
    |> model.with_model_timestamps()

  let post_model =
    model.new_model(
      name: "post",
      table_name: "posts",
      fields: [
        field.new()
          |> field.with_name("id")
          |> field.with_data_type(model.UUID)
          |> field.as_primary_key()
          |> field.with_constraints([model.NotNull]),
        field.new()
          |> field.with_name("title")
          |> field.with_data_type(model.String(200))
          |> field.with_constraints([model.NotNull])
          |> field.with_validation_rules([model.MinLength(5)]),
        field.new()
          |> field.with_name("content")
          |> field.with_data_type(model.Text),
        field.new()
          |> field.with_name("published")
          |> field.with_data_type(model.Boolean)
          |> field.with_constraints([model.NotNull]),
        field.new()
          |> field.with_name("user_id")
          |> field.with_data_type(model.UUID)
          |> field.with_constraints([model.NotNull]),
      ],
      relationships: [],
    )
    |> model.with_model_timestamps()

  let db_config =
    app_spec.DatabaseConfig(
      host: "localhost",
      port: 5432,
      database: "genau_db",
      user: "postgres",
      password: None,
    )

  // Create base app spec with automatic migration tracking
  let base_app_spec =
    app_spec.new(models: [user_model, post_model], database: db_config)

  // Demonstrate migration pipeline operations
  let age_field =
    field.new()
    |> field.with_name("age")
    |> field.with_data_type(model.Int)
    |> field.with_constraints([model.NotNull])
    |> field.with_default("0")

  let final_app_spec =
    base_app_spec
    |> migrations.add_field("user", age_field)
    |> migrations.rename_field("user", "bio", "description")
  // Add more migration operations here as needed

  // Generate to the parent directory's generated/ folder
  case generator.generate_and_write(final_app_spec, "src") {
    Ok(_files) -> io.println("✅ Code generation complete!")
    Error(error) -> {
      io.println("❌ Generation failed:")
      case error {
        generator.ValidationError(msg) ->
          io.println("Validation error: " <> msg)
        generator.FileWriteError(msg) -> io.println("File write error: " <> msg)
      }
    }
  }
}
