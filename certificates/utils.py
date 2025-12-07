import qrcode
import tempfile
from io import BytesIO
from django.core.files.base import ContentFile
from weasyprint import HTML
from django.template.loader import render_to_string

def generate_certificate_pdf(certificate):
    # Générer QR code avec URL de vérification
    qr = qrcode.QRCode(box_size=10, border=4)
    verification_url = f"https://votre-site.com/verify/{certificate.certificate_code}/"
    qr.add_data(verification_url)
    qr.make(fit=True)
    img = qr.make_image(fill_color="black", back_color="white")

    # Sauver QR code dans un buffer
    buffer = BytesIO()
    img.save(buffer, format="PNG")
    qr_data = buffer.getvalue()
    buffer.close()

    # Générer HTML template
    html_string = render_to_string("certificates/certificate_template.html", {
        "user": certificate.user,
        "course": certificate.course,
        "issued_at": certificate.issued_at,
        "qr_code": qr_data.hex(),  # on convertira côté template
        "certificate_code": certificate.certificate_code
    })

    # Générer PDF
    pdf_file = HTML(string=html_string).write_pdf()

    # Sauver dans FileField
    certificate.pdf_file.save(
        f"certificate_{certificate.user.id}_{certificate.course.id}.pdf",
        ContentFile(pdf_file),
        save=True
    )
