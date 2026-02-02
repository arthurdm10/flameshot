// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2017-2019 Alejandro Sirgo Rica & Contributors

#include "ocrtool.h"
#include <QApplication>
#include <QClipboard>
#include <QFileInfo>
#include <QPainter>
#include <memory>
#include <tesseract/baseapi.h>

#if USE_WAYLAND_CLIPBOARD
#include <KSystemClipboard>
#include <QMimeData>
#endif

#include "abstractlogger.h"
#include "confighandler.h"

OcrTool::OcrTool(QObject* parent)
  : AbstractActionTool(parent)
{
}

bool OcrTool::closeOnButtonPressed() const
{
    return false;
}

QIcon OcrTool::icon(const QColor& background, bool inEditor) const
{
    Q_UNUSED(inEditor)
    return QIcon(iconPath(background) + "ocr.svg");
}

QString OcrTool::name() const
{
    return tr("OCR Tool");
}

CaptureTool::Type OcrTool::type() const
{
    return CaptureTool::TYPE_OCR;
}

QString OcrTool::description() const
{
    return tr("Copy text to clipboard");
}

CaptureTool* OcrTool::copy(QObject* parent)
{
    auto* tool = new OcrTool(parent);
    copyParams(this, tool);
    return tool;
}

void OcrTool::pressed(CaptureContext& context)
{
    auto api = std::make_unique<tesseract::TessBaseAPI>();

    const QString tessDataPath = ConfigHandler().tessDataPath();

    if (tessDataPath.isEmpty()) {
        AbstractLogger::error()
          << "Tesseract data path is not set. Please set it in the settings.";
        emit requestAction(REQ_CLOSE_GUI);
        return;
    }

    const auto fileInfo = QFileInfo(tessDataPath);
    const auto lang = fileInfo.baseName().toLower().toStdString();

    const auto dataPath = fileInfo.path().toStdString();

    if (api->Init(dataPath.c_str(), lang.c_str()) != 0) {
        AbstractLogger::error() << "Could not initialize Tesseract.";
        emit requestAction(REQ_CLOSE_GUI);
        return;
    }

    QImage image = context.selectedScreenshotArea().toImage();
    if (image.isNull()) {
        AbstractLogger::error() << "Failed to get image from selection.";
        emit requestAction(REQ_CLOSE_GUI);
        return;
    }

    image = image.convertToFormat(QImage::Format_RGB888);

    api->SetImage(image.bits(),
                  image.width(),
                  image.height(),
                  3,
                  image.bytesPerLine());
    api->SetSourceResolution(90);

    char* detectedText = api->GetUTF8Text();

    if (detectedText == nullptr) {
        AbstractLogger::error() << "No text was found";
    } else {
        QString text = QString::fromUtf8(detectedText);
        delete[] detectedText;

        if (text.trimmed().isEmpty()) {
            AbstractLogger::info() << "OCR Result is empty.";
        } else {
            AbstractLogger::info() << "Text copied to clipboard";
            const auto clipboard = QApplication::clipboard();
            clipboard->setText(text, QClipboard::Clipboard);
        }
    }

    emit requestAction(REQ_CLOSE_GUI);
}