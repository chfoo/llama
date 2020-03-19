package llama;

import utest.Runner;
import utest.ui.Report;

class TestAll {
    public static function main() {
        var runner = new Runner();
        runner.addCases(llama.test);
        Report.create(runner);
        runner.run();
    }
}
