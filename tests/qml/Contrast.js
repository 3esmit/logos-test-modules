.pragma library

function luminance(color) {
    function linear(channel) {
        return channel <= 0.04045 ? channel / 12.92
                                 : Math.pow((channel + 0.055) / 1.055, 2.4);
    }
    return 0.2126 * linear(color.r) + 0.7152 * linear(color.g)
            + 0.0722 * linear(color.b);
}

function ratio(first, second) {
    const a = luminance(first);
    const b = luminance(second);
    return (Math.max(a, b) + 0.05) / (Math.min(a, b) + 0.05);
}

// Read the composited host image, not an isolated transparent Text grab.
// Search glyph pixels so antialiasing and platform font metrics need no golden.
function renderedRatio(image, host, label) {
    const origin = label.mapToItem(host, 0, 0);
    const scaleX = image.width / host.width;
    const scaleY = image.height / host.height;
    const background = image.pixel(0, 0);
    let maximum = 1;
    for (let y = Math.ceil(origin.y * scaleY);
         y < Math.min(image.height, (origin.y + label.height) * scaleY); ++y) {
        for (let x = Math.ceil(origin.x * scaleX);
             x < Math.min(image.width, (origin.x + label.width) * scaleX); ++x) {
            maximum = Math.max(maximum, ratio(image.pixel(x, y), background));
        }
    }
    return maximum;
}
