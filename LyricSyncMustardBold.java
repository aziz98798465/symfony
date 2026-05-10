import java.util.Arrays;
import java.util.Comparator;

public class LyricSyncMustardBold {
    public static final String MUSTARD_BOLD = "\u001B[1;33m";
    public static final String RESET = "\u001B[0m";

    public static void main(String[] args) {
        LyricLine[] lyrics = {
            new LyricLine(43.0, 0.0, "I'm the reporter, baby, you could be the news"),
            new LyricLine(46.5, 0.0, "Cause you're the cigarette and I'm the smoker"),
            new LyricLine(50.0, 0.0, "We raise a bet 'cause you're the joker"),
            new LyricLine(53.5, 0.0, "Checked off, you are the chalk"),
            new LyricLine(56.5, 0.0, "And I can be the blackboard"),
            new LyricLine(59.5, 0.0, "You can be the talk"),
            new LyricLine(61.5, 0.0, "And I can be the walk, yeah"),
            new LyricLine(65.0, 0.0, "Even when the sky comes falling"),
            new LyricLine(68.5, 0.0, "Even when the sun don't shine"),
            new LyricLine(72.0, 0.0, "I got faith in you and I"),
            new LyricLine(75.0, 0.0, "So put your pretty little hand in mine"),
            new LyricLine(79.0, 0.0, "Even when we're down to the wire, babe"),
            new LyricLine(82.5, 0.0, "Even when it's do or die"),
            new LyricLine(86.0, 0.0, "We could do it, baby, simple and plain"),
            new LyricLine(90.0, 0.0, "'Cause this love is a sure thing")
        };

        double fps = 30.0;
        Arrays.sort(lyrics, Comparator.comparingLong(line -> line.startMillis(fps)));
        long programStart = System.currentTimeMillis();

        for (int i = 0; i < lyrics.length; i++) {
            long targetMs = lyrics[i].startMillis(fps);
            waitUntil(programStart + targetMs);

            long duration;
            if (i < lyrics.length - 1) {
                long nextTargetMs = lyrics[i + 1].startMillis(fps);
                duration = Math.max(nextTargetMs - targetMs, 400);
            } else {
                duration = 2500;
            }

            typewrite(lyrics[i].text(), duration);
        }
    }

    private static void waitUntil(long targetTimeMs) {
        while (true) {
            long remaining = targetTimeMs - System.currentTimeMillis();
            if (remaining <= 0) {
                return;
            }

            try {
                Thread.sleep(remaining);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                return;
            }
        }
    }

    private static void typewrite(String text, long duration) {
        // Finishing the type time at 80% of the available time for a natural pause
        long charDelay = (long) ((duration * 0.8) / Math.max(text.length(), 1));
        charDelay = Math.max(25, Math.min(charDelay, 80));

        System.out.print(MUSTARD_BOLD);
        for (char c : text.toCharArray()) {
            System.out.print(c);
            System.out.flush();
            try {
                Thread.sleep(charDelay);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
        }
        System.out.println(RESET);
    }

    private record LyricLine(double startSec, double startFrame, String text) {
        private long startMillis(double fps) {
            return (long) ((startSec * 1000) + (startFrame / fps * 1000));
        }
    }
}
