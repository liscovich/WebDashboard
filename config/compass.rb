# This configuration file works with both the Compass command line tool and within Rails.
# Require any additional compass plugins here.
project_type = :rails

# Set this to the root of your project when deployed:
http_path = "/"
css_dir = "../public/stylesheets"
http_stylesheets_path = "/stylesheets"
sass_dir = "views/stylesheets"
images_dir = "../public/images"
http_images_path = "/images"

output_style = :compressed
environment = :production

relative_assets = true



# If you prefer the indented syntax, you might want to regenerate this
# project again passing --syntax sass, or you can uncomment this:
# preferred_syntax = :sass
# and then run:
# sass-convert -R --from scss --to sass views/stylesheets scss && rm -rf sass && mv scss sass
