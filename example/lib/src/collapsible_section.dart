import 'package:flutter/material.dart';

import 'app_theme.dart';

/// One card of options or examples, as the page's scroll views lay it out.
class DemoSection {
  const DemoSection({
    required this.title,
    required this.child,
    this.summary,
    this.subtitle,
    this.flush = false,
  });

  /// Also the section's identity, so its open state survives rebuilds.
  final String title;

  /// The current values, shown in the header while the card is closed.
  final String? summary;

  /// Shown under the title while the card is open.
  final String? subtitle;

  final Widget child;

  /// Lets list rows run edge to edge inside the card.
  final bool flush;
}

/// A card whose header opens and closes it, built as slivers so an open
/// card's header stays pinned while the card is on screen. The card grows
/// rather than scrolling inside the page: a touch drag that reaches the end
/// of an inner scroll area does not move the page on, so it would trap it.
class CollapsibleSection extends StatefulWidget {
  const CollapsibleSection({
    super.key,
    required this.section,
    required this.open,
    required this.onToggle,
  });

  final DemoSection section;
  final bool open;
  final VoidCallback onToggle;

  @override
  State<CollapsibleSection> createState() => _CollapsibleSectionState();
}

class _CollapsibleSectionState extends State<CollapsibleSection> {
  final _header = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final CollapsibleSection(:section, :open, :onToggle) = widget;
    final scheme = Theme.of(context).colorScheme;
    const radius = BorderRadius.all(Radius.circular(Gaps.m));
    final body = Padding(
      padding: section.flush
          ? const EdgeInsets.symmetric(vertical: Gaps.s)
          : const EdgeInsets.all(Gaps.m),
      child: section.child,
    );
    // The border paints over the pinned header, so the card's edge runs on
    // unbroken past it while its top has scrolled away.
    return DecoratedSliver(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: radius,
      ),
      sliver: DecoratedSliver(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: radius,
        ),
        sliver: SliverMainAxisGroup(
          slivers: [
            PinnedHeaderSliver(
              child: _Header(
                key: _header,
                section: section,
                open: open,
                onToggle: onToggle,
              ),
            ),
            SliverToBoxAdapter(
              child: _SectionScope(
                header: _header,
                child: _Body(open: open, child: body),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The height of the pinned header over the card [context] sits in, or 0
/// outside a card's content, so a reveal can keep a field clear of it.
double pinnedHeaderAbove(BuildContext context) {
  final scope = context.getInheritedWidgetOfExactType<_SectionScope>();
  final box = scope?.header.currentContext?.findRenderObject();
  return box is RenderBox && box.hasSize ? box.size.height : 0;
}

class _SectionScope extends InheritedWidget {
  const _SectionScope({required this.header, required super.child});

  final GlobalKey header;

  @override
  bool updateShouldNotify(_SectionScope oldWidget) => false;
}

/// The card's content, kept while closed so typed text and state survive.
class _Body extends StatelessWidget {
  const _Body({required this.open, required this.child});

  final bool open;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final content = Visibility(
      visible: open,
      maintainState: true,
      child: child,
    );
    // A zero-length AnimatedSize re-lays itself out mid-layout, so reduced
    // motion skips it altogether.
    if (MediaQuery.disableAnimationsOf(context)) return content;
    return AnimatedSize(
      duration: _duration(context),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: content,
    );
  }
}

Duration _duration(BuildContext context) =>
    MediaQuery.disableAnimationsOf(context)
    ? Duration.zero
    : const Duration(milliseconds: 200);

class _Header extends StatelessWidget {
  const _Header({
    super.key,
    required this.section,
    required this.open,
    required this.onToggle,
  });

  final DemoSection section;
  final bool open;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    const corner = Radius.circular(Gaps.m);
    final detail = open ? section.subtitle : section.summary;
    return Material(
      // Opaque, so the content scrolling under a pinned header stays hidden.
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: open
            ? const BorderRadius.vertical(top: corner)
            : const BorderRadius.all(corner),
      ),
      clipBehavior: Clip.antiAlias,
      child: MergeSemantics(
        child: Semantics(
          expanded: open,
          child: InkWell(
            onTap: onToggle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 56),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      Gaps.m,
                      Gaps.s,
                      Gaps.s,
                      Gaps.s,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                section.title,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: scheme.primary,
                                ),
                              ),
                              if (detail != null) ...[
                                const SizedBox(height: Gaps.s / 4),
                                Text(
                                  detail,
                                  // A summary is a glance; the card holds the rest.
                                  maxLines: open ? null : 1,
                                  overflow: open ? null : TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: Gaps.s),
                        AnimatedRotation(
                          turns: open ? 0.5 : 0,
                          duration: _duration(context),
                          child: Icon(
                            Icons.expand_more,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: Gaps.s),
                      ],
                    ),
                  ),
                ),
                if (open) const Divider(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
