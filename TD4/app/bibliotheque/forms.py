from django.forms import ModelForm
from django.utils.translation import gettext_lazy as _
from . import models

class LivreForm(ModelForm):
    class Meta:
        model = models.Livre
        fields = ('titre', 'auteur', 'date_parution', 'nombre_pages','resume')
        labels = {
            'titre' : _('Titre'),
            'auteur' : _('Auteur') ,
            'date_parution' : _('date de parution'),
            'nombre_pages' : _('nombres de pages'),
            'resume' : _('Résumé')
        }
        localized_fields = ('date_parution',)

"""
class LivreForm2(ModelForm):
    titre = forms.CharField(label="Titre", max_length=100)
    auteur = forms.CharField(label="Auteur", max_length=100)
    date_parution = forms.DateField(label="date de parution", localize=True)
    nombre_pages = forms.IntegerField(label="Nombre de pages")
    resume = forms.Textarea(label="Résumé")
"""