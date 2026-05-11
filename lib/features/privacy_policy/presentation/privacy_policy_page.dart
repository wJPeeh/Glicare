import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glicare_app_bar.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

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
              'TRANSPARÊNCIA & SEGURANÇA',
              style: GoogleFonts.manrope(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurfaceVariant,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Política de Privacidade',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
                letterSpacing: -1,
                height: 1.05,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Sua privacidade é o alicerce do Glicare. Esta política detalha como protegemos seus dados biométricos e pessoais enquanto você foca na sua saúde.',
              style: GoogleFonts.manrope(
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 28),
            _PrivacySection(
              icon: Icons.storage,
              tint: AppColors.primary,
              title: 'Coleta de Dados',
              content: 'Coletamos informações essenciais para o monitoramento glicêmico preciso, incluindo:',
              bullets: const [
                'Dados de Identificação (Nome, CPF, Data de Nascimento)',
                'Informações Biométricas (Níveis de Glicose, Peso, Altura)',
                'Logs de Atividade Física e Dieta',
              ],
            ),
            _PrivacySection(
              icon: Icons.insights,
              tint: AppColors.secondary,
              title: 'Uso das Informações',
              content:
                  'Utilizamos seus dados para gerar gráficos de tendência, calcular o Tempo em Faixa (TIR) e fornecer alertas preventivos de hipo e hiperglicemia. O processamento é realizado sob rigorosos protocolos de criptografia.',
            ),
            _PrivacySection(
              icon: Icons.lock,
              tint: AppColors.primary,
              title: 'Segurança',
              content:
                  'Implementamos criptografia de ponta a ponta (AES-256) e autenticação de dois fatores. Seus dados são armazenados em servidores de alta segurança com certificação HIPAA.',
              link: 'Certificação Azure Vital',
            ),
            _PrivacySection(
              icon: Icons.swap_horiz,
              tint: AppColors.secondary,
              title: 'Compartilhamento de Dados',
              content:
                  'Respeitamos a interoperabilidade da saúde pública. Seus dados podem ser integrados à Rede Nacional de Dados em Saúde (RNDS) para facilitar seu atendimento no Sistema Único de Saúde (SUS), garantindo que seu histórico clínico acompanhe você em qualquer unidade de atendimento.',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppColors.softShadow(opacity: 0.04),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Seus Direitos (LGPD)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _RightItem(
                      icon: Icons.edit_document,
                      title: 'Acesso e Correção',
                      desc: 'Você pode solicitar o relatório completo dos seus dados e corrigir qualquer imprecisão a qualquer momento.'),
                  _RightItem(
                      icon: Icons.delete_forever,
                      title: 'Exclusão Permanente',
                      desc: 'O direito ao esquecimento permite que você remova permanentemente todos os seus dados de nossos servidores.'),
                  _RightItem(
                      icon: Icons.upload_file,
                      title: 'Portabilidade',
                      desc: 'Exporte seu histórico de saúde em formato JSON ou PDF para levar a outros prestadores de serviço.'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'Última atualização: 24 de Maio de 2024',
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrivacySection extends StatelessWidget {
  const _PrivacySection({
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
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: tint, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
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
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.verified_outlined, size: 16, color: tint),
                const SizedBox(width: 6),
                Text(
                  link!,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: tint,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _RightItem extends StatelessWidget {
  const _RightItem({required this.icon, required this.title, required this.desc});
  final IconData icon;
  final String title;
  final String desc;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 26),
            child: Text(
              desc,
              style: GoogleFonts.manrope(
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
