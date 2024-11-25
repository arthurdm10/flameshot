// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2017-2019 Alejandro Sirgo Rica & Contributors

#include "ocrtool.h"
#include <leptonica/allheaders.h>
#include <tesseract/baseapi.h>
#include <QPainter>
#include <QClipboard>
#include <QApplication>

#include "abstractlogger.h"

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
    return tr("Set OCR as current tool");
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

    // Initialize with English language (eng)
    if (api->Init(NULL, "eng")) {
        AbstractLogger::error() << "Could not initialize tesseract.";
    } 
    const auto sc = context.selectedScreenshotArea();
    const auto scImg = sc.toImage();

    Pix* pix = pixCreate(scImg.width(), scImg.height(), scImg.depth());
    pix->data = (l_uint32*)scImg.bits();

    api->SetImage(pix);
    
    const char* detectedText = api->GetUTF8Text();

    if(detectedText == nullptr) {
        AbstractLogger::error() << "No text was found";
    } else {
        AbstractLogger::info() << "Text copied to clipboard";
        const auto clipboard = QApplication::clipboard();
        clipboard->setText(detectedText, QClipboard::Clipboard);
        // Pixa* pixa;
        // const auto boxa = api->GetTextlines(true, true, &pixa, nullptr, nullptr);

        // char info[1024];
        // sprintf(info, "X: %d Y %d -- W: %d Y: %d", boxa->box[0]->x, boxa->box[0]->y, boxa->box[0]->w, boxa->box[0]->h);
    }
  
    emit requestAction(REQ_CLOSE_GUI);
    api->End();
    return;

}
