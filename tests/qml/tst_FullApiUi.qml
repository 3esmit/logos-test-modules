import QtQuick
import QtTest
import "../../test-fullapi-ui-module/src/qml" as FullApiUi
import "Contrast.js" as Contrast

Item {
    id: root
    width: 800
    height: 480

    Rectangle { id: hostBackground; anchors.fill: parent }

    QtObject {
        id: backendStub
        readonly property string boundTarget: "test_fullapi_cpp"
        readonly property string status: "ALL_OK:test_fullapi_cpp"
        readonly property string lastEvent: "stringEvent:hello"
    }
    QtObject {
        id: logos
        function module(name) { return backendStub; }
    }
    Component { id: viewComponent; FullApiUi.Main {} }

    TestCase {
        name: "FullApiUiContrast"
        when: windowShown

        function test_labelsRemainReadable_data() {
            const rows = [];
            for (const host of ["#ffffff", "#000000"]) {
                for (const label of ["targetText", "statusText", "eventText"])
                    rows.push({ tag: host + "-" + label, host: host, label: label });
            }
            return rows;
        }

        function test_labelsRemainReadable(data) {
            hostBackground.color = data.host;
            const view = createTemporaryObject(viewComponent, root);
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
