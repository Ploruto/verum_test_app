import gleam/io
import verum/core/app_spec.{AppSpec}
import verum/core/generator
import verum/core/model.{
  DateTime, Field, Model, NotNull, PrimaryKey, String, Unique,
}

pub fn main() -> Nil {
  io.println("🔧 Generating code for test_app...")

  let user_model =
    model.Model(
      name: "user",
      // lowercase for consistency
      table_name: "users",
      fields: [
        model.Field(
          name: "id",
          data_type: model.Int,
          constraints: [model.PrimaryKey, model.NotNull],
          validation_rules: [],
        ),
        model.Field(
          name: "name",
          data_type: model.String(100),
          constraints: [model.NotNull],
          validation_rules: [model.MinLength(2)],
        ),
        model.Field(
          name: "email",
          data_type: model.String(255),
          constraints: [model.NotNull, model.Unique],
          validation_rules: [model.ValidEmail],
        ),
        model.Field(
          name: "bio",
          data_type: model.Text,
          constraints: [],
          // Optional field
          validation_rules: [],
        ),
      ],
      relationships: [],
    )
    |> model.with_model_timestamps()
  // Add created_at, updated_at

  let post_model =
    model.Model(
      name: "post",
      table_name: "posts",
      fields: [
        model.Field(
          name: "id",
          data_type: model.UUID,
          constraints: [model.PrimaryKey, model.NotNull],
          validation_rules: [],
        ),
        model.Field(
          name: "title",
          data_type: model.String(200),
          constraints: [model.NotNull],
          validation_rules: [model.MinLength(5)],
        ),
        model.Field(
          name: "content",
          data_type: model.Text,
          constraints: [],
          validation_rules: [],
        ),
        model.Field(
          name: "published",
          data_type: model.Boolean,
          constraints: [model.NotNull],
          validation_rules: [],
        ),
        model.Field(
          name: "user_id",
          data_type: model.UUID,
          constraints: [model.NotNull],
          validation_rules: [],
        ),
      ],
      relationships: [],
    )
    |> model.with_model_timestamps()

  let app_spec = AppSpec(models: [user_model, post_model])

  // Generate to the parent directory's generated/ folder
  case generator.generate_and_write(app_spec, "src") {
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
