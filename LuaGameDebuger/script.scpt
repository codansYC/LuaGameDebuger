FasdUAS 1.101.10   ��   ��    k             l     ����  I    ��  	
�� .sysoexecTEXT���     TEXT  m      
 
 �    p w d _ s t r = $ 1 
 i f   [     $ U S E R   =   r o o t     ] ; t h e n 
 e c h o   ' E r r o r :   P l e a s e   r e r u n   t h i s   s c r i p t   a s   u s e r   . ' 
 e x i t   1 
 f i 
 U S E R _ N A M E = $ U S E R 
 i f   [   !   - d   $ { H O M E } / L u a G a m e S i t e s   ] ;   t h e n 
 m k d i r   $ { H O M E } / L u a G a m e S i t e s   
 $ p w d _ s t r 
 f i 
 c d   $ { H O M E } / L u a G a m e S i t e s 
 t o u c h   i n d e x . h t m l 
 e c h o   ' a l l   r i g h t ! '   |   s u d o   t e e   - a   i n d e x . h t m l 
 e c h o   ' > :   c r e a t e   / e t c / a p a c h e 2 / u s e r s / $ { U S E R _ N A M E } . c o n f ' 
 c d   / e t c / a p a c h e 2 / u s e r s 
 s u d o   t o u c h   $ { U S E R _ N A M E } . c o n f 
 e c h o   ' # A u t h e r   t a m e r '   | s u d o   t e e   $ { U S E R _ N A M E } . c o n f 
 e c h o   ' < D i r e c t o r y   " / U s e r s / $ { U S E R _ N A M E } / L u a G a m e S i t e s / " > '   | s u d o   t e e   - a   $ { U S E R _ N A M E } . c o n f 
 e c h o   ' O p t i o n s   I n d e x e s   M u l t i V i e w s   F o l l o w S y m L i n k s '   | s u d o   t e e   - a   $ { U S E R _ N A M E } . c o n f 
 e c h o   ' A l l o w O v e r r i d e   A l l '   | s u d o   t e e   - a   $ { U S E R _ N A M E } . c o n f 
 e c h o   ' O r d e r   a l l o w , d e n y '   | s u d o   t e e   - a   $ { U S E R _ N A M E } . c o n f 
 e c h o   ' A l l o w   f r o m   a l l '   | s u d o   t e e   - a   $ { U S E R _ N A M E } . c o n f 
 e c h o   ' R e q u i r e   a l l   g r a n t e d '   | s u d o   t e e   - a   $ { U S E R _ N A M E } . c o n f 
 e c h o   ' < / D i r e c t o r y > '   | s u d o   t e e   - a   $ { U S E R _ N A M E } . c o n f 
 s u d o   c h m o d   7 7 5   $ { U S E R _ N A M E } . c o n f 
 c d   / e t c / a p a c h e 2 / 
 e c h o   ' > :   b a c k u p   f o r   / e t c / a p a c h e 2 / h t t p d . c o n f ' 
 e c h o   $ p w d _ s t r   |   s u d o   - S   c p   h t t p d . c o n f   h t t p d . c o n f . b a c k u p 
 e c h o   ' > :   r e s e t t i n g   f o r   h t t p d . c o n f ' 
 
 c d   / e t c / a p a c h e 2 / 
 #  ��R� 
 i f   c a t   / e t c / a p a c h e 2 / h t t p d . c o n f   |   g r e p   '   * S e r v e r N a m e   * l u a g a m e . c o m ' > / d e v / n u l l 
 t h e n 
 e c h o   ' Y E S ' 
 e l s e 
 e c h o   ' < V i r t u a l H o s t   * : 8 0 > '   | s u d o   t e e   - a   h t t p d . c o n f 
 e c h o   '     S e r v e r N a m e   l u a g a m e . c o m '   | s u d o   t e e   - a   h t t p d . c o n f 
 e c h o   '     D o c u m e n t R o o t   ' $ { H O M E } / L u a G a m e S i t e s / ' '   | s u d o   t e e   - a   h t t p d . c o n f 
 e c h o   ' < / V i r t u a l H o s t > '   | s u d o   t e e   - a   h t t p d . c o n f 
 f i 
 e c h o   ' > :   r e s e t t i n g   f o r   D N S   M a p ' 
 i f   c a t   / e t c / h o s t s   |   g r e p   ' 1 2 7 . 0 . 0 . 1   * l u a g a m e . c o m ' > / d e v / n u l l 
 t h e n 
 e c h o   ' Y E S ' 
 e l s e 
 e c h o   ' 1 2 7 . 0 . 0 . 1   l u a g a m e . c o m '   | s u d o   t e e   - a   / e t c / h o s t s 
 f i 
 e c h o   $ p w d _ s t r   |   s u d o   - S   a p a c h e c t l   r e s t a r t 
 c h m o d   7 7 7   $ { H O M E } / L u a G a m e S i t e s 
 e c h o   ' > :   a l l   f i n i s h ! ' 
 	 �� ��
�� 
badm  m    ��
�� boovtrue��  ��  ��     ��  l     ��������  ��  ��  ��       ��  ��    ��
�� .aevtoappnull  �   � ****  �� ����  ��
�� .aevtoappnull  �   � ****  k         ����  ��  ��        
����
�� 
badm
�� .sysoexecTEXT���     TEXT�� ��el ascr  ��ޭ