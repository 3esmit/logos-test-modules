import QtQuick
import QtTest
import "../../test-fullapi-ui-qml-module" as FullApiUiQml
import "Contrast.js" as Contrast

Item {
    id: root
    width: 800
    height: 480

    Rectangle { id: hostBackground; anchors.fill: parent }

    Component { id: viewComponent; FullApiUiQml.Main {} }

    TestCase {
        name: "FullApiUiQmlContrast"
        when: windowShown

        function test_labelsRemainReadable_data() {
            const rows = [];
            for (const host of ["#ffffff", "#000000"]) {
                for (const label of ["statusText", "eventStatusText"])
                    rows.push({ tag: host + "-" + label, host: host, label: label });
            }
            return rows;
        }

        function test_labelsRemainReadable(data) {
            hostBackground.color = data.host;
            const view = createTemporaryObject(viewComponent, root, {
                status: qsTr("ALL_OK_QML:test_fullapi_cpp"),
                eventStatus: qsTr("ALL_EVENTS_OK_QML:test_fullapi_cpp")
            });
            verify(!!view, "Component exists");
            const label = findChild(view, data.label);
            verify(!!label, "Object exists");
            verify(label.text.length > 0);
            verify(waitForRendering(view));
            const image = grabImage(root);
            compare(Contrast.ratio(label.color, image.pixel(0, 0)) >= 4.5, true);
            compare(Contrast.renderedRatio(image, root, label) >= 4.5, true);
        }
    }
}
