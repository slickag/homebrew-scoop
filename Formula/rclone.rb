class Rclone < Formula
  desc "Rsync for cloud storage"
  homepage "https://rclone.org/"
  url "https://github.com/rclone/rclone/archive/refs/tags/v1.71.2.tar.gz"
  sha256 "54c619a2f6921981f276f01a12209bf2f2b5d94f580cd8699e93aa7c3e9ee9ba"
  license "MIT"
  head "https://github.com/rclone/rclone.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/slickag/scoop"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "8657c692526ca7e55c4bb7e63ca8c896e1161c9f374e24bf25623269babdd077"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "27358fbca09b49c42a66d0a21e0c3d5c20fe8d39ce06238a6d9330fa6499bd46"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "344f175c1df778955c108b994a46c2019c112477efaccea8350f07bfbd2c15ca"
    sha256 cellar: :any_skip_relocation, sequoia:       "b460b870adf51873da73b33bd10476cf82c8e3e1199cde9328366111389d356e"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "ad0343747ccb42f06e1b09153bb7866cc2de4c455a4f267e6b661f39f784e60b"
  end

  depends_on "go" => :build

  on_linux do
    depends_on "libfuse@2"
  end

  def install
    ENV["GOPATH"] = prefix.to_s
    ENV["GOBIN"] = bin.to_s
    ENV["GOMODCACHE"] = "#{HOMEBREW_CACHE}/go_mod_cache/pkg/mod"
    ENV["CGO_FLAGS"] = "-g -O3"
    args = ["GOTAGS=cmount"]
    system "make", *args
    man1.install "rclone.1"
    system bin/"rclone", "genautocomplete", "bash", "rclone.bash"
    system bin/"rclone", "genautocomplete", "zsh", "_rclone"
    system bin/"rclone", "genautocomplete", "fish", "rclone.fish"
    bash_completion.install "rclone.bash" => "rclone"
    zsh_completion.install "_rclone"
    fish_completion.install "rclone.fish"
  end

  test do
    (testpath/"file1.txt").write "Test!"
    system bin/"rclone", "copy", testpath/"file1.txt", testpath/"dist"
    assert_match File.read(testpath/"file1.txt"), File.read(testpath/"dist/file1.txt")
  end
end
