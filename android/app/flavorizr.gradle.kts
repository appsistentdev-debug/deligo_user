import com.android.build.gradle.AppExtension

val android = project.extensions.getByType(AppExtension::class.java)

android.apply {
    flavorDimensions("flavor-type")

    productFlavors {
        create("deligo") {
            dimension = "flavor-type"
            applicationId = "com.deligo.app"
            resValue(type = "string", name = "app_name", value = "YourAppName")
        }
    }
}