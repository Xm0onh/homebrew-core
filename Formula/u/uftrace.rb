class Uftrace < Formula
  desc "Function graph tracer for C/C++/Rust"
  homepage "https://uftrace.github.io/slide/"
  url "https://github.com/namhyung/uftrace/archive/v0.14.tar.gz"
  sha256 "b81255bc288e79e96a5b158d4875fa6425ad51c85f4c4c8523c1defb9366ad12"
  license "GPL-2.0-only"
  revision 1
  head "https://github.com/namhyung/uftrace.git", branch: "master"

  bottle do
    sha256 x86_64_linux: "b467bbf5be975522b263a719994ddb726e7ddb36a5f6d34963acdf47bfd6d11a"
  end

  depends_on "pandoc" => :build
  depends_on "pkg-config" => :build
  depends_on "capstone"
  depends_on "elfutils"
  depends_on "libunwind"
  depends_on :linux
  depends_on "luajit"
  depends_on "ncurses"
  depends_on "python@3.11"

  def install
    # TODO: Obsolete with git master, to be removed when updating to next release
    inreplace "misc/version.sh", "deps/have_libpython2.7", "deps/have_libpython*"

    python3 = "python3.11"
    pyver = Language::Python.major_minor_version python3
    # Help pkg-config find python as we only provide `python3-embed` for aliased python formula
    inreplace Dir["check-deps/Makefile{,.check}"], "pkg-config python3", "pkg-config python-#{pyver}"

    system "./configure", *std_configure_args, "--disable-silent-rules"
    system "make", "install", "V=1"
  end

  test do
    out = shell_output("#{bin}/uftrace -A . -R . -P main #{bin}/uftrace -V")
    assert_match "dwarf", out
    assert_match "python", out
    assert_match "luajit", out
    assert_match "tui", out
    assert_match "sched", out
    assert_match "dynamic", out

    assert_match "| main() {", out
    assert_match "|   getopt_long(2, ", out
    assert_match "printf", out
    assert_match "| } /* main */", out
  end
end
