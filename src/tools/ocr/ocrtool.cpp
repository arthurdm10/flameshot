// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2017-2019 Alejandro Sirgo Rica & Contributors

#include "ocrtool.h"
#include <QApplication>
#include <QClipboard>
#include <QFileInfo>
#include <QPainter>
#include <leptonica/allheaders.h>
#include <leptonica/pix_internal.h>
#include <tesseract/baseapi.h>

#if USE_WAYLAND_CLIPBOARD
#include <KSystemClipboard>
#include <QMimeData>
#endif

#include "abstractlogger.h"
#include "confighandler.h"
OcrTool::OcrTool(QObject* parent)
  : AbstractTwoPointTool(parent)
{
    m_supportsDiagonalAdj = true;
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

void OcrTool::process(QPainter& painter, const QPixmap& pixmap)
{
    Q_UNUSED(pixmap);
    Q_UNUSED(painter);
}

void OcrTool::pressed(CaptureContext& context)
{
    tesseract::TessBaseAPI* api = new tesseract::TessBaseAPI();

    const QString tessDataPath = ConfigHandler().tessDataPath();

    if (tessDataPath.isEmpty()) {
        AbstractLogger::error()
          << "Tesseract language data path is not set. Please set it in the settings.";
        emit requestAction(REQ_CLOSE_GUI);
        api->End();
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

    const auto sc = context.selectedScreenshotArea();
    const auto scImg = sc.toImage();

    Pix* pix = pixCreate(scImg.width(), scImg.height(), scImg.depth());
    pix->data = (l_uint32*)scImg.bits();

    api->SetImage(pix);
    api->SetSourceResolution(90);

    const char* detectedText = api->GetUTF8Text();

    if (detectedText == nullptr) {
        AbstractLogger::error() << "No text was found";
    } else {
        AbstractLogger::info() << "Text copied to clipboard";
        const auto clipboard = QApplication::clipboard();
        clipboard->setText(detectedText, QClipboard::Clipboard);
    }

    emit requestAction(REQ_CLOSE_GUI);
    api->End();
    return;
}
