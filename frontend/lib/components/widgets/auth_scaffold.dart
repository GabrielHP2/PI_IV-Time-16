// Feito por Luis Felipe Pontes Mita - 25018740

import 'package:flutter/material.dart';

/// Estrutura base das telas de autenticação.
/// - Conteúdo centralizado com largura máxima (bom para web/desktop).
/// - Rolável (evita overflow com teclado ou telas baixas).
/// - [footer] fica fixo no rodapé quando há espaço sobrando.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.child,
    this.title,
    this.showBackButton = false,
    this.footer,
    this.topPadding = 24,
  });

  final Widget child;
  final String? title;
  final bool showBackButton;
  final Widget? footer;
  final double topPadding;

  static const double maxContentWidth = 420;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: title == null
          ? null

          : AppBar(
              title: Text(title!),
              automaticallyImplyLeading: false,
              leading: showBackButton

                  ? IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                      onPressed: () => Navigator.maybePop(context),
                    )

                  : null,
            ),

      body: SafeArea(

        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints:
                          const BoxConstraints(maxWidth: maxContentWidth),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(24, topPadding, 24, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            child,
                            if (footer != null) ...[
                              const Spacer(),
                              const SizedBox(height: 24),
                              footer!,
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
