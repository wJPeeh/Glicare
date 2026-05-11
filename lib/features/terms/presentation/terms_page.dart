import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glicare_app_bar.dart';
import '../../../core/widgets/gradient_button.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlicareAppBar(
        title: 'Legal',
        action: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Text(
            'Glicare',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
              fontSize: 16,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'DOCUMENTAÇÃO OFICIAL',
              style: GoogleFonts.manrope(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurfaceVariant,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Termos de Uso',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Bem-vindo ao Glicare. Estes termos regem o uso de nossa plataforma de monitoramento de saúde e precisão glicêmica. Ao acessar nosso serviço, você concorda em estar vinculado a estas diretrizes.',
              style: GoogleFonts.manrope(
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              height: 140,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primaryDim,
                    AppColors.secondary,
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Center(
                child: Icon(Icons.water_drop, color: Colors.white, size: 64),
              ),
            ),
            const SizedBox(height: 24),
            _TermSection(
              icon: Icons.description_outlined,
              tint: AppColors.primary,
              title: 'Aceitação dos Termos',
              content:
                  'Ao criar uma conta ou utilizar os serviços do Glicare, você declara que leu, compreendeu e aceita integralmente estes Termos. Este documento constitui um acordo legal entre você e a Glicare Health Solutions. Caso não concorde com qualquer parte destes termos, você deve interromper imediatamente o uso da plataforma.',
            ),
            _TermSection(
              icon: Icons.medical_services_outlined,
              tint: AppColors.secondary,
              title: 'Uso do Serviço',
              content:
                  'O Glicare fornece ferramentas de visualização de dados para auxílio no monitoramento glicêmico.',
              bullets: const [
                'Apenas para uso pessoal e não comercial.',
                'Exige conexão segura e dispositivos compatíveis.',
                'Não substitui aconselhamento médico profissional.',
              ],
            ),
            _TermSection(
              icon: Icons.shield_outlined,
              tint: AppColors.primary,
              title: 'Privacidade e Dados',
              content:
                  'Sua privacidade é nossa prioridade máxima. Utilizamos criptografia de ponta a ponta e seguimos rigorosamente a LGPD para garantir que seus dados biométricos permaneçam sob seu controle total.',
              link: 'VER POLÍTICA COMPLETA →',
            ),
            _TermSection(
              icon: Icons.verified_user_outlined,
              tint: AppColors.tertiary,
              title: 'Responsabilidades',
              content:
                  'O usuário é inteiramente responsável pela segurança da conta e pelo manuseio das credenciais de acesso. O Glicare não se responsabiliza por decisões médicas tomadas sem a supervisão de um profissional qualificado.',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time, color: AppColors.onSurfaceVariant, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Última atualização: 24 de Outubro de 2025',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: Text(
                'Dúvidas sobre estes termos?',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 12),
            GradientButton(
              label: 'Contatar Suporte',
              onPressed: () {},
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2), width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
                ),
                onPressed: () {},
                child: Text('Imprimir Termos', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TermSection extends StatelessWidget {
  const _TermSection({
    required this.icon,
    required this.tint,
    required this.title,
    required this.content,
    this.bullets,
    this.link,
  });
  final IconData icon;
  final Color tint;
  final String title;
  final String content;
  final List<String>? bullets;
  final String? link;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.softShadow(opacity: 0.04),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: tint, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.manrope(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
              height: 1.6,
            ),
          ),
          if (bullets != null) ...[
            const SizedBox(height: 8),
            ...bullets!.map((b) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 8, right: 8),
                        child: Icon(Icons.circle, size: 6, color: AppColors.onSurfaceVariant),
                      ),
                      Expanded(
                        child: Text(
                          b,
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            color: AppColors.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
          if (link != null) ...[
            const SizedBox(height: 8),
            Text(
              link!,
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: tint,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
