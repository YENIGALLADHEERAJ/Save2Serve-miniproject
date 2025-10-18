import javax.swing.*;
import java.awt.*;
import java.awt.event.*;
import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;

public class MapViewer {
    private JFrame frame;

    public MapViewer() {
        frame = new JFrame("Nearby Providers Map");
        frame.setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);
        frame.setSize(400, 200);
        frame.setLayout(new BorderLayout());

        JPanel panel = new JPanel();
        JButton viewMapButton = new JButton("View Nearby Providers on Map");
        viewMapButton.addActionListener(e -> openMap());
        
        panel.add(viewMapButton);
        frame.add(panel, BorderLayout.CENTER);
    }

    private void openMap() {
        String mapUrl = "https://www.openstreetmap.org/way/35460706#map=16/12.82359/80.04631";
        try {
            Desktop.getDesktop().browse(new URI(mapUrl));
        } catch (IOException | URISyntaxException ex) {
            JOptionPane.showMessageDialog(frame, 
                "Error opening map. Please visit: " + mapUrl,
                "Error",
                JOptionPane.ERROR_MESSAGE);
        }
    }

    public void show() {
        frame.setLocationRelativeTo(null);
        frame.setVisible(true);
    }

    public static void main(String[] args) {
        SwingUtilities.invokeLater(() -> {
            new MapViewer().show();
        });
    }
}
