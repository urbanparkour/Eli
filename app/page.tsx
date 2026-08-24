import Link from "next/link";

export default function Home() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-20">
        <div className="text-center">
          <h1 className="text-5xl font-bold text-gray-900 mb-4">ELI</h1>
          <p className="text-xl text-gray-700 mb-8">English Learning Intelligence</p>
          <p className="text-lg text-gray-600 mb-12 max-w-2xl mx-auto">
            Transform your English lessons into interactive learning experiences.
            Teachers create, ELI adapts, students learn.
          </p>

          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Link
              href="/auth/login"
              className="inline-block bg-indigo-600 hover:bg-indigo-700 text-white font-semibold py-3 px-8 rounded-lg transition-colors"
            >
              Log In
            </Link>
            <Link
              href="/auth/signup"
              className="inline-block bg-white hover:bg-gray-100 text-indigo-600 font-semibold py-3 px-8 rounded-lg border-2 border-indigo-600 transition-colors"
            >
              Sign Up
            </Link>
          </div>
        </div>

        {/* Features */}
        <div className="mt-20 grid grid-cols-1 md:grid-cols-3 gap-8">
          <div className="bg-white p-8 rounded-lg shadow">
            <h3 className="text-lg font-semibold text-gray-900 mb-3">For Teachers</h3>
            <p className="text-gray-600">
              Upload your lesson PDFs and let ELI structure them into interactive activities.
            </p>
          </div>
          <div className="bg-white p-8 rounded-lg shadow">
            <h3 className="text-lg font-semibold text-gray-900 mb-3">For Students</h3>
            <p className="text-gray-600">
              Learn English through adaptive activities tailored to your level and progress.
            </p>
          </div>
          <div className="bg-white p-8 rounded-lg shadow">
            <h3 className="text-lg font-semibold text-gray-900 mb-3">Adaptive Learning</h3>
            <p className="text-gray-600">
              ELI learns from your responses and personalizes your next activity accordingly.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
